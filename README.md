# Nagios Core Docker

Este proyecto proporciona una imagen Docker lista para usar de **Nagios Core** y sus plugins oficiales sobre Ubuntu 24.04, con Apache como servidor web.

---

## Requisitos previos

- Tener instalado [Docker](https://docs.docker.com/get-docker/) en tu sistema.
- (Opcional) Cuenta en AWS y conocimientos básicos de [ECS](https://docs.aws.amazon.com/ecs/latest/developerguide/what-is-ecs.html) si deseas desplegar en la nube.
- (Opcional) Cuenta en [GitHub](https://github.com/) para control de versiones y colaboración.

---

## 1. Crear y sincronizar un repositorio en GitHub

### a) Crear el repositorio en GitHub

1. Ingresa a [https://github.com/](https://github.com/) y accede con tu cuenta.
2. Haz clic en **New repository** (Nuevo repositorio).
3. Escribe un nombre para tu repositorio, por ejemplo: `nagios-core-docker`.
4. (Opcional) Agrega una descripción.
5. Elige si será público o privado.
6. Haz clic en **Create repository**.

### b) Sincronizar tu proyecto local con GitHub

```sh
# Inicializa git si aún no lo has hecho
git init

# Agrega todos los archivos
git add .

# Haz tu primer commit
git commit -m "Primer commit: versión inicial de Nagios Core Docker"

# Agrega el repositorio remoto (reemplaza <tu-usuario> y <tu-repo>)
git remote add origin https://github.com/<tu-usuario>/<tu-repo>.git

# Sube tu código a GitHub
git push -u origin master
```

---

## 2. Instalación y uso local

### a) Clona el repositorio

```sh
git clone https://github.com/<tu-usuario>/<tu-repo>.git
cd <tu-repo>
```

### b) Construye la imagen

Puedes personalizar el usuario y contraseña de acceso web:

```sh
docker build --build-arg NAGIOS_USER=admin --build-arg NAGIOS_PASS=miclave -t nagios-core .
```

Si no defines los argumentos, los valores por defecto serán `nagiosadmin` / `nagios`.

### c) Ejecuta el contenedor

```sh
docker run -d --name nagios -p 8080:80 nagios-core
```

### d) Accede a la interfaz web

Abre tu navegador en:  
[http://localhost:8080](http://localhost:8080)  
Usuario y contraseña: los que definiste al construir la imagen.

### e) Accede a la terminal del contenedor

```sh
docker exec -it nagios bash
```

---

## 3. Despliegue en AWS ECS

1. **Sube la imagen a un repositorio (ECR):**
   - Sigue la [guía oficial de AWS ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).

2. **Crea una tarea ECS:**
   - Usa la imagen subida.
   - Expón el puerto 80.
   - Define las variables de entorno `NAGIOS_USER` y `NAGIOS_PASS` en la definición de la tarea para mayor seguridad.

3. **Configura un balanceador de carga (opcional):**
   - Para acceso externo y alta disponibilidad.

---

## 4. Personalización

- Cambia el puerto modificando el comando `docker run` (`-p 8080:80`).
- Para cambiar el dominio, añade en el Dockerfile:
  ```dockerfile
  RUN echo "ServerName nagios.local" >> /etc/apache2/apache2.conf
  ```
  Y agrega `nagios.local` a tu `/etc/hosts`.

---

## 5. Troubleshooting

- **Ver logs:**  
  ```sh
  docker logs nagios
  ```
- **Problemas de acceso:**  
  Asegúrate de que el puerto no esté ocupado y que el usuario/contraseña sean correctos.
- **Advertencias de Apache:**  
  Puedes ignorar las advertencias sobre `ServerName` o seguir la sugerencia de personalización.

---

## 6. Recursos útiles

- [Documentación oficial de Nagios](https://www.nagios.org/documentation/)
- [Docker Docs](https://docs.docker.com/)
- [AWS ECS Docs](https://docs.aws.amazon.com/ecs/)
- [Guía de GitHub](https://docs.github.com/es/get-started/quickstart/create-a-repo)

---

## 7. script start_nagios.sh

El script start_nagios.sh sirve para iniciar correctamente los servicios de Nagios Core y Apache dentro del contenedor Docker. Sus funciones principales son:

1. **Verificar la configuración de Nagios:**  
   Antes de arrancar, revisa que la configuración de Nagios sea válida.

2. **Manejo de señales:**  
   Permite que el contenedor se apague limpiamente si recibe señales de parada (por ejemplo, cuando ECS detiene el contenedor).

3. **Iniciar Nagios y Apache:**  
   - Arranca Nagios en segundo plano.
   - Inicia Apache en primer plano (como proceso principal del contenedor).

Esto asegura que ambos servicios estén activos y que el contenedor funcione correctamente en Docker o AWS ECS.

## Notas

- El script `start_nagios.sh` debe estar en el mismo directorio que el Dockerfile.
- La imagen elimina herramientas de compilación tras la instalación para reducir el tamaño.

## Licencia
Este proyecto se distribuye bajo la licencia MIT.