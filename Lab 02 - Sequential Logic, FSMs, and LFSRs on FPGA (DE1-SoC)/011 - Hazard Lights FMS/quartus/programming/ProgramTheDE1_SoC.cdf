/* Quartus Prime Version 24.1std.0 Build 1077 03/04/2025 SC Lite Edition */
JedecChain;
  FileRevision(JESD32A);
  DefaultMfr(6E);

  P ActionCode(Ign)
    Device PartName(SOCVHPS) MfrSpec(OpMask(0));
  P ActionCode(Cfg)
    Device PartName(5CSEMA5F31)
	File("C:/q/EEP535/Lab 2/lab2-1.2/quartus/build/DE1_SoC.sof")
    MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
  ChainType(JTAG);
AlteraEnd;
