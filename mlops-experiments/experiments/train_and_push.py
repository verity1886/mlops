#!/usr/bin/env python3
import os
import time
import shutil
from pathlib import Path

import mlflow
from mlflow.tracking import MlflowClient
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.linear_model import SGDClassifier
from sklearn.metrics import accuracy_score, log_loss
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
import joblib
import numpy as np

MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000")
EXPERIMENT_NAME = os.getenv("MLFLOW_EXPERIMENT_NAME", "demo")
PUSHGATEWAY_URL = os.getenv("PUSHGATEWAY_URL", "http://localhost:9091")

print("MLFLOW_TRACKING_URI =", MLFLOW_TRACKING_URI)
print("PUSHGATEWAY_URL =", PUSHGATEWAY_URL)
print("EXPERIMENT_NAME =", EXPERIMENT_NAME)

mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
mlflow.set_experiment(EXPERIMENT_NAME)

iris = datasets.load_iris()
X = iris["data"]
y = iris["target"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.25, random_state=42, stratify=y
)

learning_rates = [0.01, 0.05, 0.1]
epochs_list = [100, 200]

runs_info = []

for lr in learning_rates:
    for epochs in epochs_list:
        with mlflow.start_run() as run:
            run_id = run.info.run_id

            print(f"Run {run_id}: lr={lr}, epochs={epochs}")

            model = SGDClassifier(
                loss="log_loss",
                learning_rate="constant",
                eta0=lr,
                max_iter=epochs,
                tol=1e-3,
                random_state=42
            )

            start = time.time()
            model.fit(X_train, y_train)
            train_time = time.time() - start

            probs = model.predict_proba(X_test)
            preds = np.argmax(probs, axis=1)

            acc = accuracy_score(y_test, preds)
            eps = 1e-15
            loss = log_loss(y_test, np.clip(probs, eps, 1 - eps))

            # Log params/metrics to MLflow
            mlflow.log_params({"model": "SGDClassifier", "learning_rate": lr, "epochs": epochs})
            mlflow.log_metrics({"accuracy": float(acc), "loss": float(loss), "train_time_s": float(train_time)})

            artifacts_dir = Path("artifacts")
            artifacts_dir.mkdir(exist_ok=True)
            model_path = artifacts_dir / f"model_lr{lr}_ep{epochs}.joblib"
            joblib.dump(model, model_path)
            mlflow.log_artifact(str(model_path), artifact_path="model")

            try:
                registry = CollectorRegistry()
                g_acc = Gauge("mlflow_accuracy", "Accuracy from MLflow run", ["run_id"], registry=registry)
                g_loss = Gauge("mlflow_loss", "Loss from MLflow run", ["run_id"], registry=registry)
                g_acc.labels(run_id=run_id).set(float(acc))
                g_loss.labels(run_id=run_id).set(float(loss))
                push_to_gateway(PUSHGATEWAY_URL, job=f"mlflow_training_{EXPERIMENT_NAME}", registry=registry)
            except Exception as e:
                print("[WARN] Push to PushGateway failed:", e)

            runs_info.append({
                "run_id": run_id,
                "accuracy": float(acc),
                "loss": float(loss),
                "model_file": str(model_path)
            })

best = max(runs_info, key=lambda r: (r["accuracy"], -r["loss"]))
print("Best run:", best)

# Копіюємо модель у best_model/
best_dir = Path("best_model")
if best_dir.exists():
    shutil.rmtree(best_dir)
best_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(best["model_file"], best_dir / "model.joblib")

print("Best model saved to ./best_model/model.joblib")
print("All runs logged to tracking server:", MLFLOW_TRACKING_URI)
