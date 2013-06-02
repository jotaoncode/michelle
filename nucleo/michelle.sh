#!/bin/bash
#variables de modulos

export MichelleModulos=
export MichelleTemporales=
ConfigMComando=/etc/michelle/modulos/normales.cfg
ConfigMPeriodicos=/etc/michelle/modulos/periodicos.cfg

#PARA AUDITORIA
export IPVALOR=
export AuditoriaLimite=
#PARA CONTROL DE CARGA
export LimiteCPU=
export ProcesoConsumidor=
export VecesNice=
#PARA SEGURIDAD
export SEGURIDAD=
#PARA SESIONES
export MaxUser=
#PARA MODULO LIMITACIONES
export LimitacionesMaxCPU=
export LimitacionesMaxMEM=
export LimitacionesMaxSOCKETS=
export LimitacionesMaxPROC=
export LimitacionesMaxARCHIVOS=
ACTUALIZACIONREALIZADA=0
INICIAMAL="/home/$USER/$USER.log"
RegistrarModulos()
{        
  posicion=0                                           #LA PRIMERA POSICION DE MI VECTOR DE MODULOS
  ConfigModulosComando=`cat /etc/michelle/modulos/normales.cfg`
  #        ConfigModulosPeriodicos=`cat /etc/michelle/modulos/periodicos.cfg`
  for CModulo in $ConfigModulosComando
  do
    modulo=`echo $CModulo | grep "$USER" | cut -d ':' -f1`
    if [ "$modulo" != "" ]                                #NO PUEDEN QUEDAR POSICIONES VACIAS EN MI VECTOR
    then
      ModuloComando[$posicion]=$modulo
      posicion=$(($posicion+1))
    fi 
  done
  posicion=0
  #        for CModulo in $ConfigModulosPeriodicos
  #        do
  #        modulo=`echo $CModulo | grep "$USER" | cut -d ':' -f1`
  #        if [ "$modulo" != "" ]                                #NO PUEDEN QUEDAR POSICIONES VACIAS EN MI VECTOR
  #        then
  #            ModuloPeriodico[$posicion]=$modulo
  #            posicion=$(($posicion+1))
  #        fi 
  #        done
  #        ActualizacionPeriodicos=`date -r $ConfigMPeriodicos`
  ActualizacionComando=`date -r $ConfigMComando`
  #        echo "$ActualizacionPeriodicos es la ultima actualizacion de periodicos"
  echo "los modulos comando son ${ModuloComando[*]}"
  #        echo "los modulos periodicos son ${ModuloPeriodico[*]}"
}


IniciaModulos()
{
  for modulo in $(seq 0 $((${#ModuloComando[*]} - 1)))
  do
    . ${ModuloComando[$modulo]} Iniciar
    case $? in
      0)
        echo "El modulo No pudo ser Inciado!! ${ModuloComando[$modulo]}" 
        echo "Se Procedera a cerrar la sesion"
        echo "El modulo No pudo ser Inciado!! ${ModuloComando[$modulo]}" 1>>$INICIAMAL
        exit 1;;
      1)
        echo "El modulo se inicio bien ${ModuloComando[$modulo]}";;
    esac
  done
  #    for modulo in $(seq 0 $((${#ModuloPeriodico[*]} - 1)))
  #    do
  #        . ${ModuloPeriodico[$modulo]} Iniciar
  #        case $? in
  #             0)
  #            echo "El modulo No pudo ser Inciado!! ${ModuloPeriodico[$modulo]}" 
  #            echo "Se Procedera a cerrar la sesion"
  #            echo "El modulo No pudo ser Inciado!! ${ModuloPeriodico[$modulo]}" 1>>INICIAMAL
  #        exit 1;;
#             1)
  #            echo "El modulo se inicio bien ${ModuloPeriodico[$modulo]}";;
  #        esac
  #    done

}
ProcesarModulosComando()
{
  for modulo in $(seq 0 $((${#ModuloComando[*]} - 1)))
  do
    . ${ModuloComando[$modulo]} Procesar "$*" 
    case $? in
      0)
        echo "El modulo ${ModuloComando[$modulo]} genero error"         #POR ENUNCIADO NO EJECUTA SIGUIENTES MODULOS
        echo "No se ejecutara dicho comando"
        return 0;;
      1)
        echo "El modulo ${ModuloComando[$modulo]} Proceso correctamente "
        ;;
    esac
  done
  return 1
}   
ProcesarModulosPeriodicos()
{
  for modulo in $(seq 0 $((${#ModuloPeriodico[*]} - 1)))
  do
    . ${ModuloPeriodico[$modulo]} Procesar "$*"
    case $? in
      0)
        echo "El modulo ${ModuloPeriodico[$modulo]} genero error"        #POR ENUNCIADO SE CIERRA CUANDO HAY ERROR
        echo "Por lo tanto se cerrara la sesion"
        exit 1;;
      1)
        echo "El modulo se Proceso bien ${ModuloPeriodico[$modulo]}";;
    esac
  done
}
DetenerModulos()
{
  for modulo in $(seq 0 $((${#ModuloComando[*]} - 1)))
  do
    . ${ModuloComando[$modulo]} Detener
    case $? in
      0)
        echo "El modulo No pudo ser Detenido!! ${ModuloComando[$modulo]}"
        exit 1;;
      1)
        echo "El modulo se Detuvo bien ${ModuloComando[$modulo]}";;
    esac
  done
  #    for modulo in $(seq 0 $((${#ModuloPeriodico[*]} - 1)))
  #    do
  #        . ${ModuloPeriodico[$modulo]} Detener
  #        case $? in
  #             0)
  #            echo "El modulo No pudo ser Detenido!! ${ModuloPeriodico[$modulo]}"
  #        exit 1;;
#             1)
  #            echo "El modulo se Detuvo bien ${ModuloPeriodico[$modulo]}";;
  #        esac
  #    done

}
InformacionModulos()
{
  for modulo in $(seq 0 $((${#ModuloComando[*]} - 1)))
  do
    . ${ModuloComando[$modulo]} Informacion
    case $? in
      0)
        echo "El modulo No pudo brindar Informacion!! ${ModuloComando[$modulo]}"
        exit 1;;
      1)
        echo "El modulo brindo Informacion bien ${ModuloComando[$modulo]}";;
    esac
  done
  #    for modulo in $(seq 0 $((${#ModuloPeriodico[*]} - 1)))
  #    do
  #        . ${ModuloPeriodico[$modulo]} Informacion
  #        case $? in
  #             0)
  #            echo "El modulo No pudo brindar Informacion!! ${ModuloPeriodico[$modulo]}"
  #        exit 1;;
#             1)
  #            echo "El modulo brindo Informacion bien ${ModuloPeriodico[$modulo]}";;
  #        esac
  #    done

}
verificarCambios ()
{
  retorno=1
  compararMComando=`date -r $ConfigMComando`
  #    compararMPeriodico=`date -r $ConfigMPeriodicos`

  if [ "$compararMComando" != "$ActualizacionComando" ]
  then 
    retorno=0
  fi
  #if [ "$compararMPeriodico" != "$ActualizacionPeriodicos" ]
  #then
  #    retorno=0
  #fi
  return $retorno
}
embebidos=`help`
RegistrarModulos
IniciaModulos
echo $UltimaActualizacion
echo Bienvenido $USER a michelle 
date
echo
echo -n "[Michelle]@$USER: "
while true
do
  if [ $ACTUALIZACIONREALIZADA -eq 1 ]   #ES PARA NO PERDER EL PROMPT LUEGO DEL CONTINUE DE LA ACTUALIZACION
  then
    echo -n "[Michelle]@$USER: "
    ACTUALIZACIONREALIZADA=0
  fi
  read linea
  if [ "$linea" = "" ]
  then
    verificarCambios
    if [ $? -eq 0 ]
    then
      DetenerModulos
      RegistrarModulos
      IniciaModulos
    fi
    continue
  else
    paracase=`echo $linea | awk '{print $1}'`
    case $paracase in
      Ayuda) 
        echo "Ayuda: Muestra esta informacion"
        echo "Informacion: Muestra acerca de alguno de los modulos o de todos si no se especifica"
        echo "ListarModulos: Muestra modulos asignados del usuario"
        echo "ActualizarModulos: invoca a actualizar modulos"
        echo "Salir: logout del sistema"
        echo "Apagar: apaga la pc"
        ;;
      Informacion)
        InformacionModulos 
        ;;
      ListarModulos)
        echo "Modulos NORMALES:"
        for modulo in $(seq 0 $((${#ModuloComando[*]} - 1)))
        do
          echo "${ModuloComando[$modulo]}"
        done
        echo "Modulos TEMPORALES"
        for modulo in $(seq 0 $((${#ModuloPeriodico[*]} - 1)))
        do
          echo "${ModuloPeriodico[$modulo]}"
        done
        echo
        ;;
      ActualizarModulos)             
        DetenerModulos
        RegistrarModulos
        IniciaModulos
        ;;
      Detener)
        DetenerModulos;;
      Salir)
        DetenerModulos
        echo "Sesion cerrada correctamente"
        exit 1;;
      Apagar)
        echo "Se apagara el equipo"
        /sbin/shutdown -P 10
        ;;
      *)
        ProcesarModulosComando $linea
        if [ $? -eq 1 ]
        then
          if [ "${linea:${#linea}-1}" = "&" ]
          then
            comandoMichelle=`echo "$linea" | cut -d '&' -f1`
            comandoFinal="$comandoMichelle>/dev/null"
            bash -c "$comandoFinal" &
          else
            embebido=`echo help | grep "$linea" | wc -l`
            if [ "$embebido" -ne 0 ]
            then
              builtin "$linea"
            else
              eval "$linea" --color
            fi
          fi
        fi
        ;;
    esac
  fi
  echo -n "[Michelle]@$USER: "
done

