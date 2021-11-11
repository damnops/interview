#!/bin/bash
### install k3s
curl -sfL https://get.k3s.io | sh -

### setup kubectl config
cp /etc/rancher/k3s/k3s.yaml /tmp/kube-config.txt
perl -pi -e 's/certificate-authority-data:.*/insecure-skip-tls-verify: true/g' /tmp/kube-config.txt
perl -pi -e "s/127.0.0.1/$(curl -sS http://169.254.169.254/latest/meta-data/public-ipv4)/g" /tmp/kube-config.txt

### setup download service
kubectl create configmap kube-config --from-file /tmp/kube-config.txt
cat > /tmp/kube-config.yaml <<_EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: "kube-config"
          mountPath: "/usr/share/nginx/html/kube-config.txt"
          subPath: "kube-config.txt"
      restartPolicy: Always
      volumes:
        - name: "kube-config"
          configMap:
            name: "kube-config"
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      nodePort: 30000
_EOF

### start download service
kubectl apply -f /tmp/kube-config.yaml
