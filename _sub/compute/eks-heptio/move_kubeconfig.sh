# Define varibales
SOURCE=$1
DEST=$2

# Move file
echo "Moving file $SOURCE to $DEST"
mkdir -p `dirname $DEST`
mv $SOURCE $DEST