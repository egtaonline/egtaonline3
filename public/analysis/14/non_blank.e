Traceback (most recent call last):
  File "Subgames.py", line 205, in <module>
    main()
  File "Subgames.py", line 175, in main
    known = read(args.k)
  File "/nfs/wellman_ls/egtaonline/GameAnalysis/GameIO.py", line 28, in read
    return detect_and_load(data)
  File "/nfs/wellman_ls/egtaonline/GameAnalysis/GameIO.py", line 42, in detect_and_load
    raise IOError(one_line("could not detect format: " + data_str, 71))
IOError: could not detect format: 
Traceback (most recent call last):
  File "AnalysisScript.py", line 150, in <module>
    main(args)
  File "AnalysisScript.py", line 94, in main
    subgames = read(args.sg)
  File "/nfs/wellman_ls/egtaonline/GameAnalysis/GameIO.py", line 28, in read
    return detect_and_load(data)
  File "/nfs/wellman_ls/egtaonline/GameAnalysis/GameIO.py", line 42, in detect_and_load
    raise IOError(one_line("could not detect format: " + data_str, 71))
IOError: could not detect format: 
cp: cannot create regular file `/nfs/wellman_ls/egtaonline/analysis/186/subgame/186-subgame.json': Permission denied