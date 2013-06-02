#!/bin/bash
#####################################MODULO DE AUDITORIA##########################################
##RECIBE PARAMETRO##
#VARIABLES DEL NUCLEO
#IPVALOR
#AuditoriaLimite
comando="$2"
   case "$1" in
       Informacion)
           	echo ""
           	echo "LOS VALORES ESTABLECIDOS POR CONFIGURACION PARA AUDITORIA SON"
		echo ""
                echo "El IP: $IPVALOR" 
                echo "El limite para el archivo de auditoria es: $AuditoriaLimite"
           	echo "El nombre de archivo para auditoria es $archivolog"
           	tamanoArchivo=`du -b $archivolog | awk '{print $1}'` #TAMANO ACTUAL DEL ARCHIVO
           	echo "El size del archivo de auditoria es: $tamanoArchivo"
                echo ""
                return 1;;
       Procesar)
                echo "el comando es $comando"
           	tamanoArchivo=`du -b $archivolog | awk '{print $1}'` #TAMANO ACTUAL DEL ARCHIVO
                tamanoComando=`echo "$comando" | awk 'BEGIN {FS="XXXXXXX"} {print length($1)}'`          
                tamanoTotal=$[$tamanoArchivo+$tamanoComando]                    #ES EL DEL ARCHIVO MAS EL DEL COMANDO :)
           	if [ "$AuditoriaLimite" -ge "$tamanoTotal" ]
           	then 
           	    echo "$comando">>$archivolog
           	else
                    enviar="bash -c \"echo $comando>>/home/jars/jars.log\""
           	    ssh $IPVALOR $enviar  
           	fi
                return 1;;
       Detener)
                unset IPVALOR
                unset AuditoriaLimite
                return 1;;
       Iniciar)

        archivolog="/home/$USER/$USER.log"   
        #TOME TAMBIEN EL NOMBRE DEL USUARIO PARA SABER POR SI LAS MOSCAS :)
        touch $archivolog    
        for valores in `cat /etc/michelle/modulos/Auditoria/config/$USER`            #POR AHORA CONFIG.TXT 
        do
            PrimerCampo=`echo $valores | cut -d ':' -f1`
            if [ $PrimerCampo = "IP" ]
            then
                IPVALOR=`echo $valores | cut -d ':' -f2`
            fi
            if [ $PrimerCampo = "BYTESMAX" ]
            then
                AuditoriaLimite=`echo $valores | cut -d ':' -f2`
            fi
        done
        return 1;;
       *)
         	echo "NO ES UNA LLAMADA A MODULO AUDITORIA CORRECTA";;
    esac


