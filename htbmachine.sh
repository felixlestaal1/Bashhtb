#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
function ctrl_c(){
  echo -e "\n\n${redColour}[!]Saliendo....${endColour}\n"
  tput cnorm;exit 1 
}
#Variables globales
main_url="https://htbmachines.github.io/bundle.js"
#Ctrl+c
trap ctrl_c INT 
function helpPanel(){
			cat powa.txt
  echo -e "\n${redColour}[+]${endColour}${purpleColour}Uso:${endColour}\n"
  echo -e "\t${yellowColour}u)${endColour}${purpleColour}Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${yellowColour}i)${endColour}${purpleColour}Buscar por la direccion IP${endColour}"
  echo -e "\t${yellowColour}d)${endColour}${purpleColour}Buscar por la dificultad de una maquina${endColour}"
  echo -e "\t${yellowColour}y)${endColour}${purpleColour}Obtener el link de la maquina para su resolucion${endColour}"
  echo -e "\t${yellowColour}o)${endColour}${purpleColour}Buscar por sistema operativo${endColour}"
  echo -e "\t${yellowColour}m)${endColour}${purpleColour}Buscar por un nombre de máquina${endColour}" 
  echo -e "\t${yellowColour}s)${endColour}${purpleColour}Buscar por skills${endColour}" 
  echo -e "\t${yellowColour}h)${endCOlour}${purpleColour}Mostrar panel de ayuda\n${endColour}"
}

function updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${purpleColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Todos los archivos han sido descargados${endColour}\n"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Comprobando si hay actualizaciones pendientes....${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    if [ "$md5_temp_value == $md5_original_value" ];then
      echo -e "\n${yellowColour}[+]${endColour}${purpleColour}No se detectaron actualizaciones, esta todo al dia ;)${endColour}\n"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Se han encontrado actualizacione${endColour}\n"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Se han realizado las actualizaciones${endColour}\n"
    fi
    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ *//')"
  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Listando las propiedades de la máquina${endColour}${redColour} $machineName${endColour}${purpleColour}:${endColour}\n"
    searchMachines="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ *//')"
    echo -e "\n${yellowColour}[+]${endColour}${purpleColour}$searchMachines${endColor}\n"
  else
    echo -e "\n${redColour}[!]La maquina proporcionada no existe${endColour}\n"
  fi
}

function searchIP(){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '""' | tr -d ',')"
  if [ "$machineName" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${purpleColour}La máquina correspondiente para la IP ${endColour}${redColour}$ipAddress ${endColour}${purpleColour}es ${endColour}${redColour}$machineName${endColour}\n"
  else 
    echo -e "\n${redColour}[!]La direccion IP proporcionada no existe${endColour}\n"
  fi
  }

function getYoutubeLink(){
  machineName="$1"
  youtubeLink="$(cat bundle.js| awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '""' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  if [ $youtubeLink ]; then
    echo -e "\n${yellowColour}[+]${endColour}${purpleColour}El tutorial para esta máquina está en el siguiente enlace: $youtubeLink${endColour}\n"
  else
    echo -e "\n${redColour}[!]La máquina proporcionada no existe${endColour}\n"
  fi
}
function getMachinesDifficulty(){
  difficulty="$1"
  result_checker="$(cat bundle.js | grep " dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '""' | tr -d "," | column)"
  if [  "$result_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Representado las máquinas que poseen un nivel de dificultad: $difficulty ${endColour}\n"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '""' | tr -d "," | column
  else
    echo -e "\n${redColour}[!]La dificultad indicada no existe${endColour}\n"
  fi
}
function getOsMachines(){
  os="$1"
  os_results="$(cat bundle.js | grep "so: \"$os"\"  -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column)"
  if [ "$os_results" ]; then
	  echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Mostrando las máquinas cuyo sistema operativo es $os:${endColour}"
	  cat bundle.js | grep "so: \"$os"\" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column
  else
	  echo -e "\n${redColour}[!]El sistema operativo indicado no existe${endColour}\n"
  fi
}

function getOSDifficultyMachines(){
	difficulty="$1"
	os="$2"
	check_results="$(cat bundle.js| grep "so: \"$os\"" -C 4 | grep " dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column)"
	if [ "$check_results" ] ; then
		echo -e "\n${yellowColour}[+]${endColour}${purpleColour}Listando máquinas de dificultad${endColour} ${greenColour}$difficulty${endColour} ${purpleColour}que tengan sistema operativo${endColour} ${greenColour}$os${endColour}${purpleColour}:${endColour}\n"
		cat bundle.js| grep "so: \"$os\"" -C 4 | grep " dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!]Se han indicado una dificultad o sistema operativo incorrectos${endColour}" 

	fi
}
function getSkill(){
	skill="$1"
	check_skill="$(cat bundle.js | grep "skills" -B 6 | grep "$skill" -i -B 6 | grep "name:" | tr -d '""' | tr -d ',' | column)"
	if [ "$check_skill" ]; then
		echo -e "\n${yellowColour}[+]${endColour}${purpleColour}A continuacion se representan las maquinas donde se utiliza la tecnica buscada $skill ${endColour}"
		cat bundle.js | grep "skills" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!]No se ha encontrado ninguna maquina con la Skill indicada${endColour}\n"
	fi
}
#Indicadores
declare -i parameter_counter=0

#Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg;do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done
#el -eq 1 aplica mas que nada para valores numeros a comparacion del ==
if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ];then
  updateFiles
elif [ $parameter_counter -eq 3 ];then
  searchIP  $ipAddress
elif [ $parameter_counter -eq 4 ];then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ];then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ];then
  getOsMachines $os
elif [ $parameter_counter -eq 7 ];then
	getSkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ];then
	getOSDifficultyMachines $difficulty $os
else
  helpPanel
fi
