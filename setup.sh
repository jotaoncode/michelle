#!/bin/bash
#ESTE ES EL SETUP PARA LA INSTALACION DE MICHELLE

DireccionMichelle=/etc/michelle
ScriptMichelle=/michelle.sh
Path_Scripts_Michelle=/usr/bin

function VerificaRoot ()
{
  if [ $UID -ne 0 ]
  then
    echo "EL USUARIO NO TIENE LOS PERMISOS SUFICIENTES"
    echo "Se debe ser usuario root para instalar desinstalar y configurar Michelle"
  exit 1
  fi
   
}
function instalar ()
{
  echo "Instalando Michelle"
  mkdir $DireccionMichelle
  mkdir $DireccionMichelle/modulos
    
  #COPIO LOS ARCHIVOS NECESARIOS Y LOS DIRECTORIOS TAMBIEN
  cp -R modulos $DireccionMichelle
  # COPIO EL NUCLEO MICHELLE EN /USR/BIN
  cp nucleo/michelle.sh $Path_Scripts_Michelle
  #COPIO LOS CONFIG DEL NUCLEO
  cp $PWD/modulos/normales.cfg $DireccionMichelle/modulos
  cp $PWD/modulos/periodicos.cfg $DireccionMichelle/modulos
 
  #CAMBIO DE PERMISOS
  chmod 755 /usr/bin/michelle.sh
  chmod 4755 /sbin/shutdown
  Fecha=`date`
  echo "La instalacion fue realizada exitosamente"
  echo "$Fecha"
#GENER LA CLAVE PARA SSH
#  echo "Por favor ingrese enter en todos los fields que pida para la generacion de la clave"
#  ssh-keygen
#  echo "Se debe tener instalado el Openssh para el Modulo Auditoria"
#  echo "Para esto se puede hacer apt-get install openssh-server" 
  return 0
}
function configurar ()
{
  echo "Ingrese nombre del usuario que hara uso de michelle como shell"
  read usuario
  chsh -s /usr/bin/michelle.sh $usuario
  return 0
}
function desinstalar ()
{
  echo "Desinstalando Michelle"
  rm -r $DireccionMichelle  # CON ESTO BORRO TODOS LOS CONTENIDOS DEL DIRECTORIO Y EL DIRECTORIO
  #PONGO LOS PERMISOS COMO ESTABAN
  chmod u+s /usr/bin/chsh
  chmod -s /sbin/shutdown
  #PONGO A TODOS LOS USUARIOS CON EL SHELL QUE TIENE POR DEFECTO
  usuarios=`cat /etc/passwd | grep "/usr/bin/michelle"`
  for usuario in $usuarios
  do
    nombreusuario=`echo "$usuario" | cut -d ':' -f1`
  chsh -s /bin/bash $nombreusuario #PONGO A TODOS LOS USUARIOS CON MICHELLE EN BASH
  done
  return 0
}
#FLUJO PRINCIPAL
VerificaRoot
case "$1" in
   instalar)
     instalar
   ;;
   desinstalar)
     desinstalar 
   ;;
   configurar)
     configurar
   ;;
   *)
     echo "NO FUE LLAMADA CORRECTA AL SETUP SCRIPT"
   ;;
esac
