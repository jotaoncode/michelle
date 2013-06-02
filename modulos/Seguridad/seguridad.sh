#!/bin/bash
################################MODULO DE SEGURIDAD##########################
#########RECIBE PARAMETRO
#VARIABLES DEL NUCLEO
#SEGURIDAD
comando="$2"
case $1 in
      Informacion)  
         echo "INFORMACION DE SEGURIDAD"
         for i in $(seq 0 $((${#SEGURIDAD[*]} - 1)))
         do
               echo "el usuario no tiene permitido el comando ${SEGURIDAD[$i]}"
         done
         return 1;;    
      Iniciar)     
         #TIENE QUE PONER TODOS LOS COMANDOS EN UN VECTOR
         i=0

         for comandos in `cat /etc/michelle/modulos/Seguridad/config/$USER`
         do
             PrimerCampo=`echo $comandos | cut -d ':' -f1`
             if [ $PrimerCampo = "COMANDO" ]
             then
                 SEGURIDAD[$i]=`echo $comandos | cut -d ':' -f2`
                 i=$(($i+1))
             fi
         done
         return 1;;
      Procesar)
         for i in $(seq 0 $((${#SEGURIDAD[*]} - 1)))
         do
            if [ $(echo "$comando" | grep -w ${SEGURIDAD[$i]} | wc -l) -eq 1 ]
            then
               echo "el usuario no tiene permitido el comando ${SEGURIDAD[$i]}"
               return 0 
            fi
         done
         return 1;;
      Detener)  
         unset SEGURIDAD    
         return 1;;    
      *)            
         echo "LLAMADA A MODULO SEGURIDAD INCORRECTA"
         return 0;;      
esac

