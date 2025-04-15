:: Activate environment with the correct PATH
call "%CD%\env1\Scripts\activate.bat"
set PATH=%CD%\local\bin;%%PATH%%
uvicorn server:app --host 0.0.0.0 --port 8000