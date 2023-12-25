
cd ..
#docker build --target runtime -t scherlac/smartstore-runtime:latest .
find . -iregex '.*\.\(csproj\|props\|targets\)' | tar -cvzf proj.tgz -T -
docker build --target build -t scherlac/smartstore-build:latest .
docker build -t scherlac/smartstore-linux:latest .
echo 'Press enter to exit...'; read dummy;
