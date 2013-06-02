#!/bin/bash
#########################################MODULO DE TRAFICO DE RED###############################
#VARIABLES DEL NUCLEO
#MAXPAQ
case $1 in

    Informacion) 
       echo "Cantidad MAXIMA de paquetes salientes $MAXPAQ"
       paquetes=$(cat "/proc/net/dev" | grep "lo:" | awk '{print $11}')       #TODOS LOS PAQUETES SALIENTES DEL NODO DE RED
       echo "Cantidad ACTUAL de paquetes salientes = $paquetes"
       return 1;;
    Iniciar)     
       for valores in `cat /etc/michelle/modulos/TraficoDeRed/config/$USER`             
       do
           PrimerCampo=`echo $valores | cut -d ':' -f1`
           if [ $PrimerCampo = "MAXIMOPAQUETES" ]
           then
               MAXPAQ=`echo $valores | cut -d ':' -f2`
           fi
       done
       return 1;;    
    Procesar)  
       paquetes=$(cat "/proc/net/dev" | grep "lo:" | awk '{print $11}')       #TODOS LOS PAQUETES SALIENTES DEL NODO DE RED
       if [ $paquetes -gt $MAXPAQ ]          # si es menor que los dados por Configuracion no hago nada sino trabajo con los sockets
       then
          procesos=$(ps u | uniq | awk ' NR>1 {print $2}')        #TOMO LOS PROCESOS ACTUALES DEL USUARIO
          for proceso in $procesos
          do
             # Aca chequeo si tiene sockets por cada proceso
             cantSockets=$(ls -l /proc/"$procesos"/fd 2>/dev/null | grep "socket" | wc -l)
             if [ $cantSockets -gt 0 ]
             then
                echo "Se procedera a eliminar al proceso $proceso"
                echo "la cantidad de sockets del mismo $cantSockets"
                kill -9 $proceso
             fi 
          done
       fi
       return 1;;
    Detener)      
       unset MAXPAQ
       return 1;;
    *)  
       echo "LLAMADA A MODULO CONTROL DE TRAFICO INCORRECTA"
       return 0;;
esac
