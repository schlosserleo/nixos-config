{pkgs, ...}: {
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [pkgs.nvidia-vaapi-driver];
    };
    nvidia = {
      modesetting.enable = true;
      open = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      videoAcceleration = true;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  environment.systemPackages = with pkgs; [
    libva-utils
    vdpauinfo
    mesa-demos
    nvtopPackages.nvidia
  ];
}
