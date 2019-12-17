from urllib.request import Request, urlopen, ssl, socket
from urllib.error import URLError, HTTPError
import json
from datetime import datetime
import re
import os
import smtplib
import sys
from pyfiglet import Figlet
import getpass

print()
print("######################################################")
print("##                                                  ##")
print("##           SSL Expiration Date check              ##")
print("##                     v1.0                         ##")
print("##                  by tikalsk                      ##")
print("##                                     17/12/2019   ##")
print("######################################################:\n")

def generate_menu(menu):
  for key in menu:
    print("{0} - {1}".format(key, menu[key]))

def checkURL(base_url, port, gmail_user, gmail_password):
  hostname = base_url
  context = ssl.create_default_context()
  try:
    with socket.create_connection((hostname, port)) as sock:
      with context.wrap_socket(sock, server_hostname=hostname) as ssock:
        data = json.dumps(ssock.getpeercert())
        obj = ssock.getpeercert()
        validacion = obj["notAfter"]
        if hasattr(obj,"notAfter"):
          print (obj["notAfter"])
    fecha_formato = r"%b %d %H:%M:%S %Y %Z"
    expira = datetime.strptime(validacion, fecha_formato)
    expiraen = expira - datetime.now()
    validez = str(expiraen)
    validez = validez[:2]
    if expiraen.days < 30:
      sent_from = gmail_user #Detalles del email de alerta
      sent_to = ["sslexpirado@gmail.com"] #Cambiar acorde a la cuenta que se use para monitorizacion
      subject = ("Alerta de expiración de certificado")
      print("ALERTA! El certificado ",base_url," expira en ",validez," dias!")
      email_text = "ALERTA! El certificado {0} expira en {1} dias!".format(base_url,validez)
      try:
        server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
        server.ehlo()
        server.login(gmail_user, gmail_password)
        server.sendmail(sent_from, sent_to, email_text)
        server.close()
        print("Email enviado.:\n")
      except Exception as e:
        print(e)
        print("Algo ha fallado.:\n")
    else:
      print("Aun queda. El certificado ",base_url," expira en ",validez," dias.:\n")
  except:
    print("Hay un error con el certificado de ",hostname,". Verifica si es SSL.:\n")


#Configuracion de la cuenta de email para enviar los alertas
gmail_user = input("Entra tu email para enviar las alertas.:\n")
type(gmail_user)
getpass.getpass(prompt="Entra tu contrasena para el email: ", stream=None)

archtxt = ""
email_text = ""

#Menu con las opciones de entrada de URLs al programa
menu = {}
menu['1']="Importar URLs desde un archivo de texto."
menu['2']="Comprobar una sola URL."
menu['3']="Exit"

generate_menu(menu)

while True:
  options=menu.keys()
  for entry in options:
    selection=input("Selecciona una opcion: ")

    if selection =='1':
      archtxt = input("Qual es el archivo de texto?:\n"); #El usuario define el archivo de texto donde tenemos las URLs y los puertos separados por una coma
      f = open(archtxt,"r+")
      with open(archtxt) as fp: #abre el archivo para analizar las lineas con las URLs
          lines = fp.readlines()
          for line in lines: #Lee cada linea del archivo de texto y verifica la fecha de validez del certificado de cada URL
            errorcoma = line.strip()
            errorcoma = errorcoma.split(",")
            errorcoma = len(errorcoma)
            if errorcoma != 2: #confirma que la linea en uso no este estructurada en formato <URL,puerto>
              print("Hay algun error en la linea ",line,)
              continue
            else:
              cleanline = line.strip()
              currentline = cleanline.split(",")
              base_url, port = currentline[0], currentline[1]
              checkURL(base_url, port, gmail_user, gmail_password)

    if selection =='2':
      base_url = input("Insertar URL:\n")
      type(base_url)
      port = input("Insertar puerto:")
      type(port)
      checkURL(base_url, port, gmail_user, gmail_password)
    if selection =='3':
      print("Gracias por usar este programa. Adios.")
      sys.exit(0)
