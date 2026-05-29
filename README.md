# kopi-infra

Infraestructura para Kopi Tools — Docker Compose para desarrollo local y manifiestos de Kubernetes para despliegue.

## Estructura

```
kopi-infra/
├── docker-compose.yml          # Levanta toda la plataforma localmente
├── .env.example                # Variables de entorno (copiar a .env)
├── postgres/
│   └── init-multiple-dbs.sh    # Crea las bases de datos al iniciar
└── k8s/
    ├── namespace.yaml
    ├── ingress.yaml
    ├── deploy.sh               # Script de despliegue
    ├── secrets/
    │   └── kopi-secrets.yaml   # TEMPLATE — no commitar con valores reales
    ├── postgres/
    ├── kopi-auth/
    ├── kopi-links/
    └── kopi-gateway/
```

## Desarrollo local con Docker Compose

### Prerequisitos
- Docker Desktop (con Docker Compose v2)

### Levantar la plataforma

```bash
# 1. Copiar y configurar variables de entorno
cp .env.example .env
# Editar .env con los valores deseados

# 2. Levantar todos los servicios
docker compose up --build

# 3. Verificar que todo está corriendo
docker compose ps
```

### Puertos locales

| Servicio      | Puerto | Descripción                    |
|---------------|--------|--------------------------------|
| kopi-gateway  | 8080   | Punto de entrada principal     |
| kopi-auth     | 8081   | Auth service (directo)         |
| kopi-links    | 8082   | Links + Tasks service (directo)|
| PostgreSQL    | 5432   | Base de datos                  |

### Probar la API

```bash
# Registrar usuario
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Usar el token obtenido
TOKEN="<access_token_from_login>"

# Crear un link
curl -X POST http://localhost:8080/api/links \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://spring.io","title":"Spring","category":"Dev","tags":"java"}'

# Listar links
curl http://localhost:8080/api/links \
  -H "Authorization: Bearer $TOKEN"
```

## Kubernetes (local — minikube / kind / Docker Desktop)

### Prerequisitos
- `kubectl` configurado
- Cluster local activo (minikube, kind, Docker Desktop K8s)
- Ingress controller NGINX instalado

### Construir imágenes locales

Desde la raíz del proyecto:

```bash
docker build -t kopi-auth:latest ../kopi-auth-bk
docker build -t kopi-links:latest ../kopi-links-bk
docker build -t kopi-gateway:latest ../kopi-gateway
```

Para minikube, cargar las imágenes en el cluster:

```bash
minikube image load kopi-auth:latest
minikube image load kopi-links:latest
minikube image load kopi-gateway:latest
```

### Configurar secrets

```bash
# Copiar el template (kopi-secrets.yaml está en .gitignore)
cp k8s/secrets/kopi-secrets.yaml.example k8s/secrets/kopi-secrets.yaml

# Generar valores base64 y editar el archivo
echo -n 'tu-password-postgres' | base64
echo -n 'tu-jwt-secret-de-al-menos-32-caracteres' | base64
```

> O crear el secret directamente con kubectl (sin necesidad del archivo yaml):
> ```bash
> kubectl create secret generic kopi-secrets --namespace kopi \
>   --from-literal=postgres-user=<user> \
>   --from-literal=postgres-password=<password> \
>   --from-literal=jwt-secret=<secret>
> ```

### Desplegar

```bash
cd k8s
chmod +x deploy.sh
./deploy.sh
```

### Acceder

Agregar a `/etc/hosts` (o `C:\Windows\System32\drivers\etc\hosts`):
```
127.0.0.1  kopi.local
```

La API estará disponible en `http://kopi.local/api/...`

O via NodePort: `http://localhost:30080/api/...`

### Remover

```bash
./k8s/deploy.sh --delete
```

## Variables de entorno

| Variable              | Default                                      | Descripción                          |
|-----------------------|----------------------------------------------|--------------------------------------|
| `POSTGRES_USER`       | `kopi`                                       | Usuario de PostgreSQL                |
| `POSTGRES_PASSWORD`   | *(requerido — definir en `.env`)*            | Contraseña de PostgreSQL             |
| `JWT_SECRET`          | *(requerido — no tiene valor por defecto)*   | Secreto JWT (min 32 chars)           |
| `JWT_EXPIRATION`      | `86400000`                                   | Expiración del token en ms (24h)     |
