#!/bin/bash
#######################################MODULO CONTROL DE CARGA#########################################
####VARIABLES DEL NUCLEO
#ProcesoConsumidor
#VecesNice
   case "$1" in
       Informacion)
           	echo ""
                echo "El limite de consumo de Cpu por configuracion es $LimiteCPU"
                echo ""
                echo "El Proceso que mas consume es $ProcesoConsumidor"
                echo ""
                echo "La cantidad de Nice realizados son $VecesNice"
                echo ""
                NiceProceso=$(ps -lF | awk -v pid=$ProcesoConsumidor '$4==pid {print $8}')
                echo "El nice actual del proceso que mas consume es $NiceProceso"
		echo ""
                echo "El proceso que mas consume Actualmente es $ProcesoConsumidor"
           	echo ""
                return 1;;
       Procesar)
                #Tomo el que mas consuma
                PidConsumidor=$(ps -lF | sort -k 6rn | awk ' NR==1 {print $4}')
                #Tomo el consumo que tiene este Proceso
                ConsumoCpu=$(ps -lF | awk -v pid=$PidConsumidor '$4==pid {print $6}')
                #EL PROCESO PUDO HABER TERMINADO Y NO PODRIA COMPARAR
                if [ "$ConsumoCpu" == "" ]
                then
                    return 1
                fi
                #Tomo el nice del proceso
                NiceProceso=$(ps -lF | awk -v pid=$PidConsumidor '$4==pid {print $8}')
                #Me fijo si el ProcesoConsumidor actual es igual al PidConsumidor tomado
                if [ $ConsumoCpu -gt $LimiteCPU ]
                then
                    if [ $PidConsumidor -eq $ProcesoConsumidor ]
                    then
                #Cuando lo es me pregunto la cantidad de VecesNice que se realizaron en el
                       if [ "$VecesNice" -le 4 ]
                       then
                #Con el NiceProceso si es menor or igual que -20 entonces lo dejo con -20 
                #Por que el nice tiene como limite -20
                          if [ "$NiceProceso" -le 20 ]
                          then
                             NiceProceso=20
                          else
                             NiceProceso=$(($NiceProceso+5))
                          fi
                          VecesNice=$(($VecesNice+1))
                          renice $NiceProceso -p $ProcesoConsumidor
                       else
                          echo "El proceso $ProcesoConsumidor supero la cantidad de Nice Maximo permitido"
                          echo "Sera eliminado"
                          kill -9 $ProcesoConsumidor
                       
fi
                    else         #el Proceso tomado no es igual al ultimo Consumidor entonces se renueva la informacion
                       if [ "$NiceProceso" -le 20 ]
                       then
                          NiceProceso=20
                       else
                          NiceProceso=$(($NiceProceso+5))
                       fi
                       VecesNice=1
                       ProcesoConsumidor=$PidConsumidor
                       renice $NiceProceso -p $ProcesoConsumidor
                    fi
                fi
                return 1
                ;;
       Detener)
                unset ProcesoConsumidor
                unset VecesNice
                unset LimiteCPU
                return 1;;
       Iniciar)
            for valores in `cat /etc/michelle/modulos/ControlCarga/config/$USER`             
            do
                PrimerCampo=`echo $valores | cut -d ':' -f1`
                if [ $PrimerCampo = "LIMITE" ]
                then
                    LimiteCPU=`echo $valores | cut -d ':' -f2`
                fi
            done
            VecesNice=0
        return 1;;
       *)
         	echo "NO ES UNA LLAMADA A MODULO CORRECTA";;
    esac
       
