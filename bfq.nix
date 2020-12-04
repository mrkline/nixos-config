# BFQ for everything but NVME, baby.
{ ... }:

{
  boot.kernelModules = [ "bfq" ];
  services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]n[1-9]", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
  '';

}
