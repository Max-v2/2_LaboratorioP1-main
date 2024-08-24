import os, sys
import shutil
import time
import subprocess

def dir(nombre):
    return os.path.normcase("./" + nombre)

def arch(carpeta,nombre):
    return os.path.normcase("./" + carpeta + "/" + nombre)


ejecutable = dir('principal')

if os.name == 'nt':
    ejecutable = ejecutable +  '.exe'

    
stream = os.popen('fpc -Co -Cr -gl -Miso principal.pas')
output = stream.read()
stream.close()

if "compiled" not in output:
    print (output)
    print ("**************************************************************************")
    print ("Su programa no compiló. Por favor corrija los errores y vuelva a ejecutar.")
    print ("**************************************************************************")
else:
    correctos = 0
    erroneos  = 0
    timeouts  = 0
    
    casos = (file for file in os.listdir(dir('entradas')) 
         if os.path.isfile(os.path.join(dir('entradas'), file)))
    
    for p in sorted(casos):
        path_entrada = arch('entradas',p)
        path_salida  = arch('salidas',p)
        path_mio     = arch('mios',p)
        path_diff    = arch('diffs',p)

        try:
            subprocess.run([ejecutable], stdin=open(path_entrada, "r")
                                       , stdout=open(path_mio, "w")
                                       , timeout=60.0, check=True)
            
            f_entrada = open(path_entrada, "r")
            entrada = f_entrada.read()[:-1]
            f_entrada.close()
            f_salida = open(path_salida, "r")
            salida = f_salida.read()
            f_salida.close()
            f_mio = open(path_mio, "r")
            output = f_mio.read()
            f_mio.close()
            
            if os.path.isfile(path_diff):
                os.remove(path_diff)

            if salida == output:
                print (" -- El caso", p[:2]," se resolvió correctamente")
                correctos += 1
            else:
                print("**********************************")
                print("El caso", p[:2], " tiene errores")
                print("La entrada es: ")
                print(entrada)
                print("Su programa genera:")
                print(output)
                print("El resultado correcto es:")
                print(salida)
                print("**********************************")
                erroneos += 1
                
                diff_process = subprocess.Popen(['diff', path_salida, path_mio]
                                                , stdout=subprocess.PIPE
                                                , stderr=subprocess.PIPE, text=True)
                stdout, stderr = diff_process.communicate()
                with open(path_diff, 'w') as f_diff:
                    f_diff.write(stdout)
                
        except subprocess.TimeoutExpired:
            print("**********************************")
            print("El caso", p[:2]
                 ," ha agotado el tiempo de ejecución, revise los loops")
            print("**********************************")
            timeouts += 1

    print ("Correctos: ", correctos, " Errores: ", erroneos, " Timeouts: ", timeouts)
