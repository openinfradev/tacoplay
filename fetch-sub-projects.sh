while read proj; do
  NAME=$(echo $proj | cut -d' ' -f1)
  URL=$(echo $proj | cut -d' ' -f2)
  TAG=$(echo $proj | cut -d' ' -f3)
  echo "Fetching project $NAME from $URL with tag $TAG..."

  if [ -d $NAME ]
  then
    cd $NAME; git fetch --tags; cd -
  else
    git clone $URL $NAME
  fi

  cd $NAME; git checkout $TAG; cd -
done < ./VERSIONS
