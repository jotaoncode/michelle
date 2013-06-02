#!/bin/bash
#############################################MODULO DE SESIONES############################
#### ESTE MODULO ES PARA EL MAXIMO DE SESIONES POR EL USUARIO!
### VARIABLES DEL NUCLEO
##MaxUser
case $1 in
  Detener)
        unset MaxUser
	return 1;; 
  Informacion)
        cantidad=`w -h -s | grep "su $USER" | wc -l`      ####CANTIDAD DE NUCLEOS CORRIENDO
        echo "La Cantidad de Sesiones Actuales es: $cantidad"
        echo "La cantidad de sesiones permitidas es $MaxUser"
	return 1;;
  Procesar)
    return 1;;
  Iniciar)
        for valores in `cat /etc/michelle/modulos/Sesiones/config/$USER`            #Tomo la informacion por Config 
        do
           PrimerCampo=`echo $valores | cut -d ':' -f1`
           if [ $PrimerCampo = "MaxUsuarios" ]
           then
              MaxUser=`echo $valores | cut -d ':' -f2`
           fi
        done
        cantidad=`w -h -s | grep "su $USER" | wc -l`
           if [ "$MaxUser" -ge "$cantidad" ]      
           then
               return 1
           else
               echo "la cantidad de sesiones es mayor que la permitida"
               return 0
           fi;;
   *)
        echo "INVOCACION A MODULO SESIONES INCORRECTA";;
esac

