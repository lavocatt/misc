NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
UNDERLINE='\033[4m'

export DEV_DIR=~/dev
export QUAY_USER=tlavocat
export TAG=$(date +"%m%d%Y-%H%M")

set -e

echo -e ${UNDERLINE} 🚀 Build artemis ${NOCOLOR}
echo
echo

cd $DEV_DIR/activemq-artemis
#echo mvn -Prelease package -DskipTests
echo mvn package -DskipTests -q
mvn package -DskipTests -q

echo
echo
echo -e ${UNDERLINE} 🚀 Build the broker image ${NOCOLOR}
echo
echo

cd $DEV_DIR/activemq-artemis-broker-image
cekit build --dry-run docker
cd target/image
cp $DEV_DIR/activemq-artemis/artemis-distribution/target/apache-artemis-2.40.0-SNAPSHOT-bin.zip apache-artemis-bin.zip
docker build .
docker tag $(docker images --format='{{.ID}}' | head -1) quay.io/$QUAY_USER/activemq-artemis-broker-image:$TAG
docker push quay.io/$QUAY_USER/activemq-artemis-broker-image:$TAG

echo
echo
echo -e ${GREEN} ✔ Broker image pushed to: quay.io/$QUAY_USER/activemq-artemis-broker-image:$TAG ${NOCOLOR}

echo
echo
echo -e ${UNDERLINE} 🚀 Build the kubernetes image ${NOCOLOR}
echo
echo

cd $DEV_DIR/activemq-artemis-broker-kubernetes-image/
awk -i inplace '/^from.*$/{$0="from: \"'quay.io/$QUAY_USER/activemq-artemis-broker-image:$TAG'\""} 1' image.yaml
cekit build --dry-run docker
cd target/image
docker build .
docker tag $(docker images --format='{{.ID}}' | head -1) quay.io/$QUAY_USER/activemq-artemis-broker-kubernetes-image:$TAG
docker push quay.io/$QUAY_USER/activemq-artemis-broker-kubernetes-image:$TAG

echo
echo
echo -e ${GREEN} ✔ Kubernetes image pushed to: quay.io/$QUAY_USER/activemq-artemis-broker-kubernetes-image:$TAG ${NOCOLOR}

# build the init image

echo
echo
echo -e ${UNDERLINE} 🚀 Build the init image ${NOCOLOR}
echo
echo

cd $DEV_DIR/activemq-artemis-broker-init-image/
awk -i inplace '/^FROM.*$/{$0="FROM \"'quay.io/$QUAY_USER/activemq-artemis-broker-kubernetes-image:$TAG'\""} 1' Dockerfile
docker build .
docker tag $(docker images --format='{{.ID}}' | head -1) quay.io/$QUAY_USER/activemq-artemis-broker-init-image:$TAG
docker push quay.io/$QUAY_USER/activemq-artemis-broker-init-image:$TAG

echo
echo
echo -e ${GREEN} ✔ Init image pushed to: quay.io/$QUAY_USER/activemq-artemis-broker-init-image:$TAG ${NOCOLOR}

echo
echo
echo -e ${UNDERLINE} 🚀 Run the build: ${NOCOLOR}
echo ./amq_deploy_broker.sh $DEV_DIR $QUAY_USER $TAG

