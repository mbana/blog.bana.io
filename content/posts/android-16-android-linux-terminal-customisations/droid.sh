#!/usr/bin/env bash
#
# Refer to the `usage` function below or run this script with `-h` or `--help` for instructions on how to use this script.
set -o errexit
set -o nounset
# set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive
VERBOSE=false
INSTALL_NIX=false
TAILSCALE_KEY="$(cat /mnt/shared/dev/TAILSCALE_KEY || cat "$(pwd)"/TAILSCALE_KEY)"

function color_stderr {
  exec 2> >(while IFS= read -r line; do printf '\033[31m%s\033[0m\n' "$line" >&2; done)
}
color_stderr

function trap_handler {
	echo "Something went wrong!"
	echo "$(caller): ${BASH_COMMAND}"
}

trap trap_handler ERR

# function EC {
# 	echo -e '\e[1;33m'code $?'\e[m\n'
# }
# trap EC ERR

function usage {
	echo "Usage: $0 [-n|--install-nix] [-v|--verbose]"
	echo ""
	echo "Options:"
	echo "  -n, --install-nix     Install Nix package manager and Home Manager"
	echo "  -v, --verbose         Show verbose output"
	echo "  -h, --help            Show this help message and exit"
	echo ""
	echo "Install Tailscale, set up SSH access, and optionally install Nix package manager and Home Manager on the VM."
	echo ""
	echo "Firstly create the following files on the Android device all under the \`Downloads\` folder:"
	echo ""
	echo "1. \`Downloads/dev/TAILSCALE_KEY\`: This should be the key for your Tailscale account, which you can generate from the Tailscale admin console."
	echo "2. \`Downloads/dev/id_ed25519\`: This should be your SSH private key."
	echo "3. \`Downloads/dev/id_ed25519.pub\`: This should be the corresponding SSH public key."
	echo ""
	echo "Then in the Android Linux Terminal guest VM, execute the following commands to set up the environment:"
	echo ""
	echo "$ bash /mnt/shared/dev/droid.sh --help"
	echo "$ bash /mnt/shared/dev/droid.sh --verbose --install-nix"
	echo ""
	echo "Once this has completed, you should be able to access the VM from another machine that is one the same Tailscale network using the following command:"
	echo ""
	echo "$ ssh -p 1986 droid@droid"
	exit 1
}

while [[ $# -gt 0 ]]; do
	case $1 in
	-n | --install-nix)
		INSTALL_NIX=true
		shift
		;;
	-v | --verbose)
		VERBOSE=true
		shift
		;;
	-h | --help)
		usage
		shift
		;;
	*)
		echo "Invalid option: $1"
		usage
		;;
	esac
done

function until_success {
	until "$@"; do
		echo "Command failed, retrying in 4 seconds ..."
		sleep 4s
		sudo dpkg --configure -a
	done
}

function install_nix_and_home_manager {
	sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
	echo "if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi" | tee -a "$HOME/.zprofile"

	nix-channel --add https://nixos.org/channels/nixos-25.11 nixpkgs
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
	nix-channel --update

	nix-shell '<home-manager>' -A install

	mkdir -pv "$HOME/dev/github/mbana"
	cd "$HOME/dev/github/mbana"
	git clone https://github.com/mbana/home-manager.git
	cd "$HOME/dev/github/mbana/home-manager"
	ln -sfv "$(pwd)/home.nix" "$HOME/.config/home-manager/home.nix"

	home-manager switch

	sudo chsh --shell "$(which zsh)" "$(whoami)"

	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
	echo '. "${HOME}/.cargo/env"' | tee -a ~/.zprofile | tee -a ~/.profile

	until_success sudo apt upgrade -y
}

function install_tailscale {
	until_success sudo apt update -y
	until_success curl -fsSL https://tailscale.com/install.sh | sh
	cat <<EOF | sudo tee -a /etc/default/tailscaled
TS_NO_LOGS_NO_SUPPORT=true
FLAGS="--no-logs-no-support --state='mem:'"
EOF
	sudo systemctl daemon-reload
	sleep 4s

	echo "sudo tailscale up --auth-key='${TAILSCALE_KEY}' --accept-dns=false --hostname=droid --ssh" | tee ~/start-tailscale.sh
	chmod +x -v ~/start-tailscale.sh
	
	~/start-tailscale.sh
}

function install_openssh {
	mkdir -v -m700 ~/.ssh
	cp -v /mnt/shared/dev/id_ed25519.pub ~/.ssh/id_ed25519.pub
	cp -v /mnt/shared/dev/id_ed25519.pub ~/.ssh/authorized_keys
	cp -v /mnt/shared/dev/id_ed25519 ~/.ssh/id_ed25519
	chmod -v 600 ~/.ssh/id_ed25519
	chmod -v 644 ~/.ssh/id_ed25519.pub
	chmod -v 644 ~/.ssh/authorized_keys

	sudo mkdir -pv /etc/ssh/sshd_config.d/
	cat <<EOF | sudo tee -a /etc/ssh/sshd_config.d/100-droid.conf
PermitRootLogin yes
PasswordAuthentication yes
Port 1986
EOF

	until_success sudo apt update -y
	until_success sudo apt install -y openssh-server vim zsh sed coreutils curl git nmap net-tools neofetch screenfetch jq lsb-release

	sudo systemctl enable --now ssh
	sudo systemctl restart --now ssh

	eval "$(ssh-agent)"
	ssh-add -v ~/.ssh/id_ed25519
}

if [ "${VERBOSE}" == true ]; then
	set -x
fi

sudo hostnamectl hostname droid

echo "droid:droid" | sudo chpasswd
echo 'droid ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers.d/100-droid

install_tailscale
install_openssh

sudo neofetch
sudo netstat -tulpn
sudo tailscale status
sleep 16s

if [ "${INSTALL_NIX}" == true ]; then
	install_nix_and_home_manager
else
	echo "Installation finished. Did not install Nix or Home Manager since the --install-nix flag was not set."
fi

echo "Please note the IP address from the following command if you want to SSH into the VM after it reboots:"
sudo tailscale status
sleep 32s
sudo systemctl reboot
