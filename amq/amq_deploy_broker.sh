set -e

DEV_DIR=$1
QUAY_USER=$2
TAG=$3

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
UNDERLINE='\033[4m'

echo -e ${UNDERLINE} 🚀 Have minkube running: ${NOCOLOR}
echo minikube start
echo minikube dashboard

echo
echo
echo -e ${UNDERLINE} 🚀 Have the operator installed: ${NOCOLOR}
echo $DEV_DIR/activemq-artemis-operator/deploy/install_opr.sh
echo kubectl get pod -n activemq-artemis-operator


echo
echo
echo type enter when done
read

echo
echo -e ${UNDERLINE} 🚀 Deploying operator: ${NOCOLOR}

cat <<EOF > /tmp/CR.yaml
apiVersion: broker.amq.io/v1beta1
kind: ActiveMQArtemis
metadata:
  name: artemis-ingress
spec:
  deploymentPlan:
    image: quay.io/$QUAY_USER/activemq-artemis-broker-kubernetes-image:$TAG
    initImage: quay.io/$QUAY_USER/activemq-artemis-broker-init-image:$TAG
EOF

kubectl apply -f /tmp/CR.yaml -n activemq-artemis-operator

echo
echo
echo -e ${UNDERLINE} when done have the operator undeployed: ${NOCOLOR}
echo $DEV_DIR/activemq-artemis-operator/deploy/undeploy_all.sh
