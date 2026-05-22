# perritos-frontend

Frontend estático para la Tienda de Alimentos para Perritos. Sirve una interfaz HTML/JS para gestionar productos via CRUD, con Nginx como servidor web y proxy hacia el backend.

## Tecnologias

- HTML5 / JavaScript (vanilla)
- Nginx 1.25 (Alpine)
- Docker (multi-stage build)

## Arquitectura

El frontend corre en una instancia EC2 en el puerto 80. Las peticiones a `/api/` son proxeadas por Nginx hacia el backend en `54.160.222.187:3001`.

```
Usuario -> EC2 Frontend (Nginx :80) -> EC2 Backend (Node.js :3001) -> MySQL :3306
```

## Estructura del repositorio

```
perritos-frontend/
├── Dockerfile
├── default.conf
├── index.html
├── app.js
└── .github/
    └── workflows/
        └── cicd-tienda-frontend.yml
```

## Pipeline CI/CD

El workflow `cicd-tienda-frontend.yml` se activa con push a la rama `deploy` y ejecuta tres pasos:

1. Build de la imagen Docker con multi-stage (Alpine + Nginx)
2. Push de la imagen a Docker Hub como `lalcaino/tienda-perritos-frontend:latest`
3. Deploy en la EC2 frontend via SSH: pull de la imagen y recreacion del contenedor

## Secrets requeridos en GitHub

| Secret | Descripcion |
|---|---|
| DOCKERHUB_USERNAME | Usuario de Docker Hub |
| DOCKERHUB_TOKEN | Token de acceso Docker Hub |
| EC2_FRONTEND_HOST | IP publica de la EC2 frontend |
| EC2_USER | Usuario SSH (ec2-user) |
| EC2_SSH_KEY | Clave privada SSH (.pem) |

## Despliegue manual

Para forzar un redeploy sin cambios de codigo:

```bash
git commit --allow-empty -m "ci: forzar redeploy"
git push origin deploy
```

## Acceso

La aplicacion queda disponible en `http://<EC2_FRONTEND_HOST>` una vez que el pipeline termina exitosamente.
