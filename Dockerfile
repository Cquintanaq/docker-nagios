# Ubuntu 24.04 imagen base
FROM ubuntu:24.04

# Variables de usuario y contraseña como ARG y ENV para mayor flexibilidad en ECS
ARG NAGIOS_USER=nagiosadmin
ARG NAGIOS_PASS=nagios
ENV NAGIOS_USER=${NAGIOS_USER}
ENV NAGIOS_PASS=${NAGIOS_PASS}

# Establecer variables de entorno para evitar mensajes interactivos durante la instalación del paquete
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites for Nagios Core and Nagios Plugins
# Based on Ubuntu 22.x/24.x section [cite: 52, 73]
# Note: ufw is not needed in Docker. libmcrypt-dev is not in Ubuntu 22.04 main repos and is skipped;
# some plugins might not build/work without it.
RUN apt-get update && \
    apt-get install -y \
    autoconf \
    gcc \
    libc6 \
    make \
    wget \
    unzip \
    apache2 \
    php \
    libapache2-mod-php \
    libgd-dev \
    openssl \
    libssl-dev \
    bc \
    gawk \
    dc \
    build-essential \
    snmp \
    libnet-snmp-perl \
    gettext \
    libperl-dev \
    libldap2-dev \
    libmysqlclient-dev \
    libpq-dev \
    libdbi-dev \
    libsnmp-dev \
    apache2-utils \
    pkg-config \
    libtool \
    curl \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Descargue e instale Nagios Core (utilizando la versión 4.4.14 como se especifica en la guía oficial de Nagios [cita: 6])
WORKDIR /tmp

RUN wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/refs/tags/nagios-4.4.14.tar.gz && \
    tar xzf nagioscore.tar.gz && \
    cd nagioscore-nagios-4.4.14 && \
    ./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
    make all && \
    make install-groups-users && \
    usermod -a -G nagios www-data && \
    make install && \
    make install-daemoninit && \
    make install-commandmode && \
    make install-config && \
    make install-webconf && \
    a2enmod rewrite && \
    a2enmod cgi && \
    htpasswd -b -c /usr/local/nagios/etc/htpasswd.users ${NAGIOS_USER} ${NAGIOS_PASS} && \
    cd /tmp && \
    rm -rf nagioscore-nagios-4.4.14 nagioscore.tar.gz

# Descargue e instale los complementos de Nagios (utilizando la versión 2.4.6 como se especifica en la guía de instalacion de nagios oficial [cita: 6, 68])
RUN wget -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/refs/tags/release-2.4.6.tar.gz && \
    tar zxf nagios-plugins.tar.gz && \
    cd nagios-plugins-release-2.4.6 && \
    ./tools/setup && \
    ./configure && \
    make && \
    make install && \
    cd /tmp && \
    rm -rf nagios-plugins-release-2.4.6 nagios-plugins.tar.gz

# Exponer el puerto 80 para el servidor web Apache
EXPOSE 80

# Healthcheck para ECS
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/nagios || exit 1

# Crear un script de inicio
COPY start_nagios.sh /usr/local/bin/start_nagios.sh
RUN chmod +x /usr/local/bin/start_nagios.sh

# Establezca el punto de entrada al script de inicio
CMD ["/usr/local/bin/start_nagios.sh"]
