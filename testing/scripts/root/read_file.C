void read_file(){
  const char *filename = gSystem->Getenv("ALRB_TESTING_FILENAME");
  cout << filename << endl; 

  TFile *tfile = TFile::Open(filename);     
  if (tfile == 0 ) {
    exit(1);
  };
  exit(0);
}
