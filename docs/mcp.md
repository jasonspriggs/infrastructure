# Master Control Program Server

## Bootstrapping the MCP server

Creating an MCP server should only need to be done rarely; ideally just once.
MCP is the central piece of MAGFest's IT infrastructure. MCP provisions and
manages the configuration of all of our other servers.

1. Create a new droplet on [https://digitalocean.com](https://digitalocean.com)
  * Ubuntu 16.04.4 x64
  * Add a block storage volume (this will need to be mounted on `/srv/data`)
  * Select "Private Networking" and "Monitoring"
  * Add the following SSH Keys: "Saltmaster", "Rob Ruana", and "DomMCP"
2. By default the salt-minions will attempt to connect to `saltmaster.magfest.net`, so the DNS entry for `saltmaster.magfest.net` should be updated to point to the new droplet's **Private IP**
3. SSH to the new server
4. Follow Digital Ocean's instructions for configuring and mounting your block storage volume on `/srv/data`.
  * If you're adding a _new_ volume, you'll need to format the volume. 
    <span class="highlight"><span class="err">This will **DESTROY** any existing data on the volume!</span></span>
```
mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_volume-nyc1-01
```
  * After formatting, or if you're mounting an already formatted volume:
```
mkdir -p /srv/data; \
mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_volume-nyc1-01 /srv/data; \
echo /dev/disk/by-id/scsi-0DO_Volume_volume-nyc1-01 /srv/data ext4 defaults,nofail,discard 0 0 | tee -a /etc/fstab
```
5. As root/sudo run the following command and follow the instructions it prints when finished:
```
curl -L https://github.com/magfest/infrastructure/raw/master/bootstrap-mcp.sh | sh
```