#define MEMSIZE 0x9000
#include "..\lib\strings.h" 
#include "..\lib\mem.h"
#include "..\lib\file_system.h"


void main()
{   
	dword dirbuf, fcount, filename, i;
	dword dirbuf2, fcount2, filename2, j;
	char cd_path[4096];
	char install_path[4096];
	signed int result;

	pause(200);
	GetDir(#dirbuf, #fcount, "/", DIRS_ONLYREAL);

	for (i=0; i<fcount; i++)
	{
		filename = i*304+dirbuf+72;
		if (!strstr(filename, "fd"))
		{
			strcpy(#cd_path, "/");
			strcat(#cd_path, filename);
			free(dirbuf2);
			GetDir(#dirbuf2, #fcount2, #cd_path, DIRS_ONLYREAL);

			for (j=0; j<fcount2; j++)
			{
				filename2 = j*304+dirbuf2+72;
				strcpy(#install_path, #cd_path);
				strcat(#install_path, "/");
				strcat(#install_path, filename2);
				strcat(#install_path, "/installer.kex");
				result = RunProgram(#install_path, NULL);
				if (result>0) ExitProcess();
			}
		}
	}
	notify("'KolibriN\n�� ���� ���� installer.kex �� � ����� ��୥ ��᪠!\n���஡�� ���� � �������� ��� ������.' -dtE");
	ExitProcess();
}


stop:
