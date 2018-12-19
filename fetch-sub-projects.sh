while read proj; do
  NAME=$(echo $proj | cut -d' ' -f1)
  URL=$(echo $proj | cut -d' ' -f2)
  TAG=$(echo $proj | cut -d' ' -f3)
  echo "Fetching project $NAME from $URL with tag $TAG..."
  git clone $URL $NAME
  cd $NAME; git checkout $TAG; cd -
done < ./VERSIONS
