#!/bin/bash
######################################MODULO CONTROL DE LIMITACIONES##################### 
#ESTE MODULO NO RECIBE PARAMETROS
#VARIABLES DEL NUCLEO
#LimitacionesMaxCPU
#LimitacionesMaxMEM
#LimitacionesMaxSCOKETS
#LimitacionesMaxARCHIVOS
#LimitacionesMaxPROC

case "$1" in
       Informacion)
           echo ""
           echo "La Informacion dada por Configuracion es:"
	   echo ""
           sumaconsumos=$(ps axu | awk "/$USERNAME/"'{cantidad+=$3} END {print cantidad}')
           sumamem=$(ps axu | awk "/$USERNAME/"'{cantidad+=$4} END {print cantidad}')
           pid=$(ps u | awk 'NR>1 {print $2}')              #NR>1 ES PARA SACARLE LA CABECERA MOLESTA
           for unPid in $pid
           do
              socketsact=`expr $ProcHijoSock + $(ls -l /proc/$unPid/fd 2>/dev/null | grep socket | wc -l)`
           done
           Archivos=$(lsof | grep -c $USERNAME | wc | awk '{for(i = 1; i<=NF ; i++) cantidad+=$i} {print cantidad}')
           Procesos=$(ps axu | awk "/$USERNAME/"'{print $1}' | grep -c $USERNAME)
           echo "LOS VALORES DADOS POR CONFIGURACION SON"
           echo "Limitacion de consumo de CPU es: $LimitacionesMaxCPU"
           echo "Limitacion de consumo de Memoria es: $LimitacionesMaxMEM"
           echo "Cantidad maxima de archivos es: $LimitacionesMaxARCHIVOS"
           echo "Cantidad maxima de procesos es: $LimitacionesMaxPROC"
           echo "Cantidad maxima de sockets es: $LimitacionesMaxSOCKETS"
           echo "LA CANTIDAD ACTUAL DE DICHOS CONSUMOS SON"
           echo "La suma de consumos de Cpu es: $sumaconsumos"
           echo "La cantidad de memoria usada es: $sumamem"
           echo "La cantidad de sockets son: $socketsact"
           echo "La cantidad de archivos: $Archivos"
           echo "La cantidad de procesos: $Procesos"

           return 1;;
       Procesar)
#LA CANTIDAD DE INFORMACION REUNIDA ES
           sumaconsumos=$(ps axu | awk "/$USERNAME/"'{cantidad+=$3} END {print cantidad}')
           sumamem=$(ps axu | awk "/$USERNAME/"'{cantidad+=$4} END {print cantidad}')
           pid=$(ps u | awk 'NR>1 {print $2}')              #NR>1 ES PARA SACARLE LA CABECERA MOLESTA
           for unPid in $pid
           do
              socketsact=`expr $ProcHijoSock + $(ls -l /proc/$unPid/fd 2>/dev/null | grep socket | wc -l)`
           done
           Archivos=$(lsof | grep -c $USERNAME | wc | awk '{for(i = 1; i<=NF ; i++) cantidad+=$i} {print cantidad}')
           Procesos=$(ps axu | awk "/$USERNAME/"'{print $1}' | grep -c $USERNAME)

           if [ $(echo "$LimitacionesMaxCPU < $sumaconsumos"|bc) -eq 1 ]
           then
               echo "Limite de Cpu excedido $sumaconsumos"
               return 0
           fi
           if [ $(echo "$LimitacionesMaxMEM < $sumamem"|bc) -eq 1 ]
           then
               echo "Limite de Memoria excedido"
               return 0
           fi
           if [ "$LimitacionesMaxSOCKETS" -lt "$socketsact" ]
           then
               echo "Limite de sockets excedido"
               return 0
           fi
           if [ "$LimitacionesMaxARCHIVOS" -lt "$Archivos" ]
           then
               echo "Limite de archivos excedido"
               return 0
           fi
           if [ "$LimitacionesMaxPROC" -lt "$Procesos" ] 
           then 
               echo "Limite de Procesos excedido"
               return 0
           fi
           return 1;;
       Detener)
           unset LimitacionesMaxCPU
           unset LimitacionesMaxMEM
           unset LimitacionesMaxPROC
           unset LimitacionesMaxSOCKETS
           unset LimitacionesMaxARCHIVOS
           return 1;;
       Iniciar)
       for valores in `cat /etc/michelle/modulos/ControlLimitaciones/config/matias`             
       do
           PrimerCampo=`echo $valores | cut -d ':' -f1`
           if [ $PrimerCampo = "CONSUMOCPU" ]
           then
               LimitacionesMaxCPU=`echo $valores | cut -d ':' -f2`
           fi
           if [ $PrimerCampo = "CONSUMOMEM" ]
           then
               LimitacionesMaxMEM=`echo $valores | cut -d ':' -f2`
           fi
           if [ $PrimerCampo = "MAXPROCESOS" ]
           then
               LimitacionesMaxPROC=`echo $valores | cut -d ':' -f2`
           fi
           if [ $PrimerCampo = "MAXSOCKETS" ]
           then
               LimitacionesMaxSOCKETS=`echo $valores | cut -d ':' -f2`
           fi
           if [ $PrimerCampo = "MAXARCHIVOS" ] 
           then
               LimitacionesMaxARCHIVOS=`echo $valores | cut -d ':' -f2`
           fi
       done
       return 1;;

       *)
        	echo "NO ES UNA LLAMADA A MODULO CORRECTA";;
    esac

