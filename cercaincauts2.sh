#!/bin/bash
# Date: 16-03-2013
# Author: "templix, pau"
# Version: 3.5
# Licence: GPL v3.0
# Description: Busca ips aleatorias con puertos abiertos
# Require: nmap ccze dialog
####
if [ "$(id -u)" != "0" ]; then
	dialog --title "INFO" --msgbox "Solo root puede ejecutar este script." 5 43
	clear	
	exit 1
fi
#
USER=$(cat /etc/passwd | grep 1000 | cut -d : -f 6)
DIR=$USER/incauts
if [ -d $DIR ]
then
	rm -R $DIR/*
	else
	mkdir $DIR
fi
clear
cd $DIR
echo
echo "<< Cuantas IPs aleatorias se han de escanear (50, 100, 1000...) >>" | ccze -A
echo
read IPS
echo
echo "<< Filtrar el PUERTO... (22, 80, 445, 5900...) >>" | ccze -A
echo
read PORT
echo
echo "<< Filtrar el ESTADO... (filtered, open, closed...) >>" | ccze -A
echo
read STAT
echo
echo
echo "<< Espere un momento....>>" | ccze -A
echo
nmap -iR $IPS -p $PORT  > nmap.txt 2>/dev/null
cat nmap.txt | sed -e '/Starting/ d' | sed -e \$d  > nmap1.txt
cat nmap1.txt | grep report | awk '{print $NF}' | cut -d "(" -f2 | cut -d ")" -f1 > nmap2.txt
cat nmap1.txt | grep $PORT/tcp | awk '{print $2}' > nmap3.txt
paste -d " " nmap2.txt nmap3.txt > nmap4.txt
cat nmap4.txt | grep '^[0-9]' | grep $STAT | awk '{print$1}' | cut -d : -f 1 > 1-IpOpen.txt
clear
echo
echo "<< Las IPs que cumplen los requisitos solicitados son: >>" | ccze -A
echo
cat 1-IpOpen.txt
echo
echo "<< Pulsar intro para continuar....>>" | ccze -A 
read
#rm nmap*.txt
echo
echo  "< ¿Proseguir el ataque al listado con los plugins de nmap? [s/n] >>" | ccze -A
read OP
sortir=0
if [ $OP = s ]
then
#clear
	while [ $sortir -eq 0 ];
	do
			echo
				touch resul_nmap.txt
				modu=($(ls -1 /usr/share/nmap/scripts | cut -d . -f 1))
				declare -p modu | sed -e 's/ /\n/g'
			read MOD
			clear
			echo
			echo "<< Procesando con el módulo $linea... >>" | ccze -A
#			echo "<< Procesando con el módulo ${scripts_nmap[MOD]}... >>"
	      		echo "${modu[MOD]}" | tee -a 1-modulo.txt
			echo
			MODU=$(cat 1-modulo.txt)
			if [ -s resul_nmap.txt ]
			then
				> resul_nmap.txt
			else
				touch resul_nmap.txt
			fi
			for linea in `cat 1-IpOpen.txt`; do
				let numero+=1
					nmap -O -sS --script=$MODU -P0 $linea -p T:$PORT  >> resul_nmap.txt
					echo "---------------------------------------" >> resul_nmap.txt
			done
		echo
		echo  "<< Escaneo  finalizado.... >>" | ccze -A
		echo
		echo  "<< ¿Visualizar los datos? [s/n] >>" | ccze -A
		read OP1
		if  [ $OP1 = s ]
		then
			if [ -s resul_nmap.txt ]
			then
				echo
				cat resul_nmap.txt
				echo
			else
				echo "No se han encontrado datos, abortando...."
				exit 1
			fi
			echo "<< Pulsar intro para continuar....>>" | ccze -A
			read
		else
			echo
		fi
		clear
		echo
		echo  "¿Desea provar otro script de ataque? [s/n]"  | ccze -A
		echo
		read continuar
		if  [ $continuar != "s" ];
		then
			sortir=1
		else
			echo
		fi
	done
else
	echo
	exit
fi
echo
echo "<< Para más consultas, el archivo de datos es resul_nmap.txt >>" | ccze -A
echo
chmod  -R 777 $USER/incauts/*
#rm 1-*.txt
exit 0
