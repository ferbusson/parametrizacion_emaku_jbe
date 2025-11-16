# directorios nomina
alias cdcn='cd /var/www/html/emaku_nomina/lib/companies/'
alias cdsn='cd /usr/local/emaku-nomina/lib/companies/'
alias cdsns='cd /usr/local/emaku-nomina/lib/emaku/'
#directorios lacali

alias update_lacali_workspace='cd /home/felipe/workspace/;jar cvf lacali.jar lacali;sacar_copia lacali.jar;rm -R lacali;rm lacali.jar;cp /var/www/html/emaku_lacali/lib/companies/lacali.jar .;jar xvf lacali.jar;chown -R felipe:felipe lacali'
alias cdc='cd /var/www/html/emaku_lacali/lib/companies/'
alias cds='cd /usr/local/emaku-lacali/lib/companies/'
alias cdss='cd /usr/local/emaku-lacali/lib/emaku/'
alias cpp='chown -R felipe:felipe /home/felipe/workspace/;cp -u /home/felipe/workspace/lacali/printer-templates/graphics/*.* /var/www/html/emaku_lacali/lib/companies/lacali/printer-templates/graphics/;cp -u /home/felipe/workspace/lacali/conf/*.* /var/www/html/emaku_lacali/lib/companies/lacali/conf/;cd /var/www/html/emaku_lacali/lib/companies/;sacar_copia lacali.jar;jar cvf lacali.jar lacali;/root/./firmar.sh lacali.jar'

alias cppn='chown -R felipe:felipe /home/felipe/workspace/nomina/;cp -u /home/felipe/workspace/nomina/lacali/printer-templates/graphics/*.* /var/www/html/emaku_nomina/lib/companies/lacali/printer-templates/graphics/;cp -u /home/felipe/workspace/nomina/lacali/conf/*.* /var/www/html/emaku_nomina/lib/companies/lacali/conf/;cd /var/www/html/emaku_nomina/lib/companies/;sacar_copia lacali.jar;jar cvf lacali.jar lacali;/root/./firmar.sh lacali.jar'

alias logemaku='tail -f /tmp/emaku-lacali.server.log'
alias logemakunomina='tail -f /tmp/nomina-emaku.log'
alias logemakunominatail='tail -n400000 /tmp/nomina-emaku.log | less'
alias logpostgres='tail -f /var/log/postgresql/postgresql-9.5-main.log'
alias logemakutailshort='tail -n200000 /tmp/emaku-lacali.server.log | less'
alias logemakutail='tail -n1000000 /tmp/emaku-lacali.server.log | less'
alias logemakutaillong='tail -n5000000 /tmp/emaku-lacali.server.log | less'
alias logpostgrestail='tail -n5000 /var/log/postgresql/postgresql-9.5-main.log | less'
alias reiniciar_emaku_all='/etc/init.d/nomina-emaku stop;/etc/init.d/emaku-lacali stop;/etc/init.d/nomina-emaku start;sleep 45;/etc/init.d/emaku-lacali start'
alias reiniciar_emaku='/etc/init.d/emaku-lacali stop;/etc/init.d/emaku-lacali start'
alias reiniciar_nomina='/etc/init.d/nomina-emaku stop;/etc/init.d/nomina-emaku start'

#Make a backup copy of a file
#Use: "backup common.jar"
#Results: makes a copy of common.jar -> common-may-20-2021.jar.bck and places it in the same directory
sacar_copia() {
   cp $@ "$(echo $@ | cut -d'.' -f 1)-$(date +'%m-%d-%Y').$(echo $@ | cut -d'.' -f 2).bck"
}
alias firmar_jar='/root/./firmar.sh'
alias generar_firmar_jar='jar cvf lacali.jar lacali;/root/./firmar.sh lacali.jar'
alias enviar_jar_sucursales='scp lacali.jar felipe@172.16.3.2:;echo ''sent to lascuadras'';scp lacali.jar felipe@172.16.7.2:;echo ''sent to unico'';scp lacali.jar felipe@172.16.5.2:;echo ''sent to granplaza'''

alias actualiar_fuentes_todas='cp /home/felipe/fuentes_todas/fuentes_cliente/*.* /var/www/html/emaku_lacali/lib/emaku/;cp /home/felipe/fuentes_todas/fuentes_servidor/*.* /usr/local/emaku-lacali/lib/emaku/;ls -ltr /usr/local/emaku-lacali/lib/emaku;ls -ltr /var/www/html/emaku_lacali/lib/emaku'
