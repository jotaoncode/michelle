#!/bin/bash
################################MODULO DE SEGURIDAD##########################
#########RECIBE PARAMETRO
#VARIABLES DEL NUCLEO
#SEGURIDAD

case "$1" in
      Informacion)  
         cat $file
         return 1;;    
      Iniciar)     
         #TIENE QUE PONER TODOS LOS COMANDOS EN UN VECTOR
         CONFIGSEGURIDAD=`cat matias`
         i=0
         for comandos in `cat matias`
         do
             PrimerCampo=`echo $comandos | cut -d ':' -f1`
             if [ $PrimerCampo = "COMANDO" ]
             then
                 i=$(echo "$i + 1"|bc) 
                 SEGURIDAD[$i]=`echo $comandos | cut -d ':' -f2`
             fi
         done
         echo "el primer valor de ${SEGURIDAD[1]} el segundo ${SEGURIDAD[2]}"
         return 0;;
      Procesar)
        i=0 
         for i in $((${#SEGURIDAD[*]} - 1))
         do
            echo "el valor de i es $i"
            echo "la cantidad de elementos de seguridad ${#SEGURIDAD[*]}"
            echo "seguridad tiene ${SEGURIDAD[$i]}"
            if [ $(echo "$2" | grep -w ${SEGURIDAD[$i]} | wc -l) -eq 1 ]
            then
               echo "el usuario no tiene permitido el comando ${SEGURIDAD[$i]}"
               return 1
            else
               echo "no lo tomo" 
               echo "$(echo "$2" | grep -w ${SEGURIDAD[$i]} | wc -l)"
            fi
      done;;
      Detener)  
          unset SEGURIDAD    
          return 1;;    
      *)            
          echo "LLAMADA A MODULO SEGURIDAD INCORRECTA"
          return 0;;      
esac
