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
--  S.P.A.T. - Map information from JSON data into internal data structure.
--
--  Collect file contents.
--
------------------------------------------------------------------------------

private with Ada.Tags;
limited private with Ada.Containers.Hashed_Maps;
with SPAT.Entity.Tree;
limited with SPAT.Strings;
with SPAT.Timing_Item;

package SPAT.Spark_Info is

   type Sorting_Criterion is (None, Name, Time);

   type T is tagged limited private;
   --  Binary representation of the information obtained from a .spark JSON
   --  file.

   ---------------------------------------------------------------------------
   --  Map_Spark_File
   --
   --  Traverses through the JSON data given in Root and translates it into
   --  the data structure given in This.
   --
   --  Must be called first before the below subroutines can be called.
   ---------------------------------------------------------------------------
   not overriding
   procedure Map_Spark_File (This : in out T;
                             File : in     File_Name;
                             Root : in     JSON_Value);

   ---------------------------------------------------------------------------
   --  List_All_Entities
   --
   --  Returns an (optionally sorted) list of all entities (source unit names)
   --  currently stored in This.
   ---------------------------------------------------------------------------
   not overriding
   function List_All_Entities
     (This    : in T;
      Sort_By : in Sorting_Criterion := Name) return Strings.Entity_Names;

   ---------------------------------------------------------------------------
   --  List_All_Files
   --
   --  Returns an (optionally sorted) list of the names of all files that have
   --  been parsed into This.
   ---------------------------------------------------------------------------
   not overriding
   function List_All_Files
     (This    : in T;
      Sort_By : in Sorting_Criterion := None) return Strings.File_Names;

   ---------------------------------------------------------------------------
   --  Num_Flows
   --
   --  Return the total number of flows (flow items) collected.
   ---------------------------------------------------------------------------
   not overriding
   function Num_Flows (This : not null access T)
                       return Ada.Containers.Count_Type;

   ---------------------------------------------------------------------------
   --  Flow_Time
   --
   --  Reported time taken for the flow analysis for File.
   ---------------------------------------------------------------------------
   not overriding
   function Flow_Time (This : in T;
                       File : in File_Name) return Duration;

   ---------------------------------------------------------------------------
   --  Num_Proofs
   --
   --  Return the total number of proofs collected.
   ---------------------------------------------------------------------------
   not overriding
   function Num_Proofs (This : not null access T)
                        return Ada.Containers.Count_Type;

   ---------------------------------------------------------------------------
   --  Proof_Time
   --
   --  Reported time taken for all the proofs for File.
   ---------------------------------------------------------------------------
   not overriding
   function Proof_Time (This : in T;
                        File : in File_Name) return Duration;

   ---------------------------------------------------------------------------
   --  Max_Proof_Time
   --
   --  Maximum time taken for a single proof for Entity.
   ---------------------------------------------------------------------------
   not overriding
   function Max_Proof_Time (This   : in T;
                            Entity : in Entity_Name) return Duration;

   ---------------------------------------------------------------------------
   --  Total_Proof_Time
   --
   --  Total (accumulated) time taken for all proofs for Entity.
   ---------------------------------------------------------------------------
   not overriding
   function Total_Proof_Time (This   : in T;
                              Entity : in Entity_Name) return Duration;

   ---------------------------------------------------------------------------
   --  Proof_List
   --
   --  List of proof items for given Entity, sorted by time.
   ---------------------------------------------------------------------------
   not overriding
   function Proof_Tree
     (This   : in T;
      Entity : in Entity_Name) return SPAT.Entity.Tree.Forward_Iterator'Class;

   ---------------------------------------------------------------------------
   --  Iterate_Children
   ---------------------------------------------------------------------------
   not overriding
   function Iterate_Children (This     : in T;
                              Entity   : in Entity_Name;
                              Position : in SPAT.Entity.Tree.Cursor)
                              return SPAT.Entity.Tree.Forward_Iterator'Class;

   ---------------------------------------------------------------------------
   --  Has_Failed_Attempts
   --
   --  Returns True if any of the proof attempts for Entity do not have a
   --  "Valid" result.
   ---------------------------------------------------------------------------
   not overriding
   function Has_Failed_Attempts (This   : in T;
                                 Entity : in Entity_Name) return Boolean;

   ---------------------------------------------------------------------------
   --  Has_Unjustified_Attempts
   --
   --  Returns True if some of the proof attempts for Entity are not "Valid"
   --  and there is no justification message.
   ---------------------------------------------------------------------------
   not overriding
   function Has_Unjustified_Attempts
     (This   : in T;
      Entity : in Entity_Name) return Boolean;

   ---------------------------------------------------------------------------
   --  Has_Unproved_Attempts
   --
   --  Returns True if some of the proof attempts for Entity do have a "Valid"
   --  result.
   ---------------------------------------------------------------------------
   not overriding
   function Has_Unproved_Attempts (This   : in T;
                                   Entity : in Entity_Name) return Boolean;

   ---------------------------------------------------------------------------
   --  Print_Trees
   --
   --  Debugging subroutine to print the trees to Standard_Output. Only does
   --  something if the Verbose flag is set.
   ---------------------------------------------------------------------------
   not overriding
   procedure Print_Trees (This : in T);

private

   type Source_Lines_Sentinel is new Entity.T with null record;

   ---------------------------------------------------------------------------
   --  Image
   ---------------------------------------------------------------------------
   overriding
   function Image (This : in Source_Lines_Sentinel) return String is
     (Ada.Tags.External_Tag (T => Source_Lines_Sentinel'Class (This)'Tag) & ": ()");

   Empty_Source_Lines_Sentinel : constant Source_Lines_Sentinel :=
     (Entity.T with null record);

   type Flows_Sentinel is new Entity.T with null record;

   ---------------------------------------------------------------------------
   --  Image
   ---------------------------------------------------------------------------
   overriding
   function Image (This : in Flows_Sentinel) return String is
     (Ada.Tags.External_Tag (T => Flows_Sentinel'Class (This)'Tag) & ": ()");

   Empty_Flows_Sentinel : constant Flows_Sentinel :=
     (Entity.T with null record);

   type Proof_Cache is
      record
         Max_Proof_Time           : Duration;
         Total_Proof_Time         : Duration;
         Has_Failed_Attempts      : Boolean;
         Has_Unproved_Attempts    : Boolean;
         Has_Unjustified_Attempts : Boolean;
      end record;

   type Proofs_Sentinel is new Entity.T with
      record
         Cache : Proof_Cache;
      end record;

   ---------------------------------------------------------------------------
   --  Image
   ---------------------------------------------------------------------------
   overriding
   function Image (This : in Proofs_Sentinel) return String is
     (Ada.Tags.External_Tag (T => Proofs_Sentinel'Class (This)'Tag) & ":" &
      ("(Max_Proof_Time => " & This.Cache.Max_Proof_Time'Image &
         ", Total_Proof_Time => " & This.Cache.Total_Proof_Time'Image &
         ", Has_Failed_Attempts => " & This.Cache.Has_Failed_Attempts'Image &
         ", Has_Unproved_Attempts => " & This.Cache.Has_Unproved_Attempts'Image &
         ")"));

   Empty_Proofs_Sentinel : constant Proofs_Sentinel :=
     (Entity.T with
      Cache => Proof_Cache'(Max_Proof_Time           => 0.0,
                            Total_Proof_Time         => 0.0,
                            Has_Failed_Attempts      => False,
                            Has_Unproved_Attempts    => False,
                            Has_Unjustified_Attempts => False));

   type Analyzed_Entity is
      record
         SPARK_File   : File_Name;          --  File the entity was found in.
         The_Tree     : Entity.Tree.T;      --  Holds all entities.
         Source_Lines : Entity.Tree.Cursor; --  Currently unused.
         Flows        : Entity.Tree.Cursor; --  List of Flow_Items
         Proofs       : Entity.Tree.Cursor; --  List of Proof_Items
      end record;

   --  Type representing a source (file) entity.
   package Analyzed_Entities is new
     Ada.Containers.Hashed_Maps (Key_Type        => Entity_Name,
                                 Element_Type    => Analyzed_Entity,
                                 Hash            => Hash,
                                 Equivalent_Keys => "=");

   package File_Timings is new
     Ada.Containers.Hashed_Maps (Key_Type        => File_Name,
                                 Element_Type    => Timing_Item.T,
                                 Hash            => Hash,
                                 Equivalent_Keys => "=",
                                 "="             => Timing_Item."=");

   type T is tagged limited
      record
         Entities : Analyzed_Entities.Map;
         Files    : File_Timings.Map;
         --  Cached data
         Flow_Count  : Ada.Containers.Count_Type'Base;
         Proof_Count : Ada.Containers.Count_Type'Base;
      end record;

end SPAT.Spark_Info;
