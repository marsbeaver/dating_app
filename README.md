# Dating app prototype

Work in progress.

Using flutter and Golang.

To test the code, do the following:

create a .env file in the root of the project and define the following variables:

```
JWT_KEY=yourkey
MONGO_URI=yourdburi
PORT=8080
DATABASE=yourdb
BASE_URL=http://localhost:8080
```

Ensure flutter is installed.

```
cd flutter_frontend
```

```
flutter build web
```

```
cd ..
```

```
docker compose up --build
```

Run localhost:80 on a browser to run the web app



