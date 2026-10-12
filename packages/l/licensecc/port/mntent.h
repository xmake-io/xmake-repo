/*
 *  mntent
 *  mntent.h - compatibility header for FreeBSD
 */

#ifndef _MNTENT_H
#define _MNTENT_H

#include <stdio.h>
#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>

#define MOUNTED "dummy"
#define MNTTYPE_NFS "nfs"

struct mntent {
    char *mnt_fsname;
    char *mnt_dir;
    char *mnt_type;
    char *mnt_opts;
    int mnt_freq;
    int mnt_passno;
};

#define setmntent(x, y) ((FILE *)0x1)
#define endmntent(x) (1)

static inline struct mntent *getmntent(FILE *fp) {
    static int pos = -1;
    static int mntsize = -1;
    static struct statfs *mntbuf = NULL;
    static struct mntent ent;

    if (pos == -1 || mntsize == -1) {
        mntsize = getmntinfo(&mntbuf, MNT_NOWAIT);
        pos = 0;
    }
    if (pos >= mntsize || mntbuf == NULL) {
        pos = -1;
        mntsize = -1;
        return NULL;
    }
    ent.mnt_fsname = mntbuf[pos].f_mntfromname;
    ent.mnt_dir = mntbuf[pos].f_mntonname;
    ent.mnt_type = mntbuf[pos].f_fstypename;
    ent.mnt_opts = (char *)"";
    ent.mnt_freq = 0;
    ent.mnt_passno = 0;
    pos++;
    return &ent;
}

#endif /* _MNTENT_H */
