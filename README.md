# Stenographer in docker container

Containerized Stenographer built from the Google project
https://github.com/google/stenographer

### Build it
```
docker build --no-cache --tag=stenographer .
```

### Run it
```
docker run -p 9005:9005 -itd --cap-add NET_RAW --cap-add NET_ADMIN --cap-add IPC_LOCK --network host --name stenographer stenographer
```
