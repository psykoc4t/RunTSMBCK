# ------------------------------------------------------------------------
# NOM: runTSMBCK.ps1
# AUTEUR: Antonio de Almeida
# DATE:28/09/2016
# Version: 1.0
#
# COMMENTAIRES:
# Permet d'exécuter la commande dsmc.exe sur un serveur distant
# ------------------------------------------------------------------------



#Récuperation des arguments
$mode = $args[0] #Type de sauvegarde IFIncremental ou full
$optfile_name = $args[1] #Le fichier opt fourni par l'équipe qui gère TSM. Il est hébergé dans le dossier où se trouve le script
$vmListFileName = $args[2] #Precise le nom du fichier de liste au cas ou il y'en aurait plusieurs

if($args.Count -lt 3)
{
		Get-Date -uformat "%Hh%M(%S) : ERR. : Argument manquant'"
		return 1
		exit
}


#Variables
$server='Mon_Serveur' #Serveur où sera exécuté la commande dsmc.exe
$vmFile= Get-Content -Path .\$vmListFileName #fichier contenant les vm's à backuper 

foreach ($vm in $vmFile)
{
	write-host 'Traitement de '$vm ' veuillez patienter...'
	

	$remotesession = new-pssession -computername $server
	
	
	invoke-command -Session $remotesession -scriptblock { $codeRetour = start-process -PassThru -FilePath dsmc.exe -ArgumentList "backup vm $using:vm -vmbackuptype=fullvm -mode=$using:mode -optfile=$using:optfile_name " -WorkingDirectory "C:\Program Files\Tivoli\TSM\baclient" -Wait; $codeRetour.ExitCode}
	$remotelastexitcode = invoke-command -ScriptBlock {$lastexitcode} -Session $remotesession | out-null
					
	$mySession = Get-PSSession
	Remove-PSSession -Session $mySession
	
	
	if($remotelastexitcode -eq 0)
	{
	return 0
	exit
	
	}elseif($remotelastexitcode -eq 8)
		{
		return 8
		exit
	
		}elseif($remotelastexitcode -eq 12)
			{
				return 12
				exit
			
			}
	
	
	

}





