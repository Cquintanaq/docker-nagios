#!/bin/bash
set -e

# Manejo de señales para apagado limpio
trap 'echo "Deteniendo Nagios y Apache..."; pkill nagios; apache2ctl stop; exit 0' SIGTERM SIGINT

echo "Verificando configuración de Nagios..."
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

echo "Configuración verificada. Iniciando Nagios y Apache..."

# Inicia Nagios en segundo plano
/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg &

# Inicia Apache en primer plano
exec /usr/sbin/apache2ctl -D FOREGROUND