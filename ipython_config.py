# Disable history manager, we don't really use it
# and by default it puts an sqlite file on NFS, which is not something we want to do
c.Historymanager.enabled = False
