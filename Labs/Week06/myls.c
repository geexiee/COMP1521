// myls.c ... my very own "ls" implementation

#include <stdlib.h>
#include <stdio.h>
#include <bsd/string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <grp.h>
#include <pwd.h>
#include <sys/stat.h>
#include <sys/types.h>

#define MAXDIRNAME 100
#define MAXFNAME   200
#define MAXNAME    20

char *rwxmode(mode_t, char *);
char *username(uid_t, char *);
char *groupname(gid_t, char *);

int main(int argc, char *argv[])
{
   // string buffers for various names
   char dirname[MAXDIRNAME];
   char uname[MAXNAME+1]; // UNCOMMENT this line
   char gname[MAXNAME+1]; // UNCOMMENT this line
   char mode[MAXNAME+1]; // UNCOMMENT this line

   // collect the directory name, with "." as default
   if (argc < 2)
      strlcpy(dirname, ".", MAXDIRNAME);
   else
      strlcpy(dirname, argv[1], MAXDIRNAME);

   // check that the name really is a directory
   struct stat info;
   if (stat(dirname, &info) < 0)
      { perror(argv[0]); exit(EXIT_FAILURE); }
   if ((info.st_mode & S_IFMT) != S_IFDIR)
      { fprintf(stderr, "%s: Not a directory\n",argv[0]); exit(EXIT_FAILURE); }

    char fullname[100];


   // open the directory to start reading
    DIR *df; // UNCOMMENT this line

	df = opendir(dirname);									// Open directory
   // read directory entries
    struct dirent *entry; 
	while ( (entry = readdir(df)) != NULL) {				// while there are more entries
		if (entry->d_name[0]== '.') {    
			continue;										// ignore if name starts with '.'
		}
	    strcpy(fullname, dirname);                          // Get the correct pathname
        strcat(fullname, "/");
        strcat(fullname, entry->d_name);
		lstat(fullname, &info);
		printf("%s  %-8.8s %-8.8s %8lld  %s\n",
		rwxmode(info.st_mode, mode),
		username(info.st_uid, uname),
		groupname(info.st_gid, gname),
		(long long) info.st_size,
		entry->d_name);
	}		

   // finish up
    closedir(df);
   return EXIT_SUCCESS;
}

// convert octal mode to -rwxrwxrwx string
char *rwxmode(mode_t mode, char *str)
{
   switch (mode & S_IFMT) {                                 //  Evaluate what type of file object you have
      case S_IFDIR: str[0] = 'd'; break;
      case S_IFLNK: str[0] = 'l'; break;
      case S_IFREG: str[0] = '-'; break;
      default: str[0] = '?'; break;
   }
   char *default_str = "rwxrwxrwx";
   int i=0;
   for (i = 0; i <= 8; i++)
   {
      if (!(mode & 1<<(8-i))) {                              // If the actual mode doesn't have a 1 in that spot, the person/group doesn't have that permission
         str[i+1] = '-';                                     // So in the permissions, set it to '-'
                                                             // Note that we use str[i+1] as string has a d/l/-/? in its first index
      }
      else {
         str[i+1] = default_str[i];                          // Otherwise they do, so copy default string (which is all permissions allowed) over
      }
   } 
   str[9] = '\0';                                            // Add null terminator
   return str;
}

// convert user id to user name
char *username(uid_t uid, char *name)
{
   struct passwd *uinfo = getpwuid(uid);
   if (uinfo == NULL)
      snprintf(name, MAXNAME, "%d?", (int)uid);
   else
      snprintf(name, MAXNAME, "%s", uinfo->pw_name);
   return name;
}

// convert group id to group name
char *groupname(gid_t gid, char *name)
{
   struct group *ginfo = getgrgid(gid);
   if (ginfo == NULL)
      snprintf(name, MAXNAME, "%d?", (int)gid);
   else
      snprintf(name, MAXNAME, "%s", ginfo->gr_name);
   return name;
}
