------------------------------------------------------------------------------
--  Copyright (C) 2020 by Heisenbug Ltd. (gh+spat@heisenbug.eu)
--
--  This work is free. You can redistribute it and/or modify it under the
--  terms of the Do What The Fuck You Want To Public License, Version 2,
--  as published by Sam Hocevar. See the LICENSE file for more details.
------------------------------------------------------------------------------
pragma License (Unrestricted);

------------------------------------------------------------------------------
--
--  SPARK Proof Analysis Tool
--
--  S.P.A.T. - String list and table support (for output formatting).
--
------------------------------------------------------------------------------

with SPAT.String_Vectors;

package SPAT.Strings is

   package Implementation is

      package Subjects is new String_Vectors (Element_Type => Subject_Name,
                                              "="    => "=",
                                              Length => Length);

      package Entities is new String_Vectors (Element_Type => Entity_Name,
                                              "="          => "=",
                                              Length       => Length);

      package File_Names is new String_Vectors (Element_Type => File_Name,
                                                "="          => "=",
                                                Length       => Length);

   end Implementation;

   --  A one dimensional list of strings.
   type Subject_Names is new Implementation.Subjects.List   with private;
   type Entity_Names  is new Implementation.Entities.List   with private;
   type File_Names    is new Implementation.File_Names.List with private;

private

   type Subject_Names is new Implementation.Subjects.List   with null record;
   type Entity_Names  is new Implementation.Entities.List   with null record;
   type File_Names    is new Implementation.File_Names.List with null record;

end SPAT.Strings;
