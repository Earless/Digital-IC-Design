when(boundp('spcInstallForm) && hiIsForm(spcInstallForm) &&
        stringp(spcInstallForm->spcPath)
    foreach(file setof(element getDirFiles(strcat( spcInstallForm->spcPath
	    "/utilities")) (index(element ".il") && equal(strlen(index(element
	    ".il")) 3)) || (index(element ".ile") && equal(strlen(index(element
	    ".ile")) 4)))
	unless(file == "spcLoadUtilities.il"
	    load(strcat(spcInstallForm->spcPath "/utilities/" file)) 
	)
    )
)
