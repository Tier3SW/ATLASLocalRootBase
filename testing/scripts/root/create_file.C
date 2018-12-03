void create_file(){
  const char *filename = gSystem->Getenv("ALRB_TESTING_FILENAME");
  TFile *tfile = TFile::Open(filename, "RECREATE", "DummyFile"); 

    TNtuple *ntuple = new TNtuple("ntuple","Demo ntuple","px:py:pz:random:i");

    Float_t px, py, pz;
    for (Int_t i = 0; i < 25000; i++) {
      gRandom->Rannor(px,py);
      pz = px*px + py*py;
      Float_t random = gRandom->Rndm(1);
      ntuple->Fill(px,py,pz,random,i);
    }

    ntuple->Write();
    tfile->Close();
    delete tfile;
    
    exit(0);
}
