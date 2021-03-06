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
--  S.P.A.T. - Object representing a JSON "proof attempt" object.
--
------------------------------------------------------------------------------

private with Ada.Tags;
with SPAT.Entity;
with SPAT.Field_Names;
with SPAT.Preconditions;

package SPAT.Proof_Attempt is

   use all type GNATCOLL.JSON.JSON_Value_Type;

   ---------------------------------------------------------------------------
   --  Has_Required_Fields
   ---------------------------------------------------------------------------
   function Has_Required_Fields (Object : JSON_Value) return Boolean is
     (Preconditions.Ensure_Field (Object => Object,
                                  Field  => Field_Names.Result,
                                  Kind   => JSON_String_Type) and
      Preconditions.Ensure_Field (Object        => Object,
                                  Field         => Field_Names.Time,
                                  Kinds_Allowed => Preconditions.Number_Kind));

   type T is new Entity.T with private;

   ---------------------------------------------------------------------------
   --  Create
   ---------------------------------------------------------------------------
   not overriding
   function Create (Object : JSON_Value;
                    Prover : Subject_Name) return T
     with Pre => Has_Required_Fields (Object => Object);

   Trivial_True : constant T;
   --  Special Proof_Attempt instance that represents a trivially true proof.
   --
   --  Since GNAT_CE_2020 we can also have a "trivial_true" in the check_tree
   --  which - unlike a proper proof attempt - has no Result nor Time value, so
   --  we assume "Valid" and "no time" (i.e. 0.0 s). These kind of proof
   --  attempts are registered to a special prover object "Trivial" (which
   --  subsequently appears in the "stats" objects).

   --  Sorting instantiations.

   ---------------------------------------------------------------------------
   --  "<"
   --
   --  Comparison operator.
   ---------------------------------------------------------------------------
   not overriding
   function "<" (Left  : in T;
                 Right : in T) return Boolean;

   ---------------------------------------------------------------------------
   --  Prover
   ---------------------------------------------------------------------------
   not overriding
   function Prover (This : in T) return Subject_Name;

   ---------------------------------------------------------------------------
   --  Result
   ---------------------------------------------------------------------------
   not overriding
   function Result (This : in T) return Subject_Name;

   ---------------------------------------------------------------------------
   --  Time
   ---------------------------------------------------------------------------
   not overriding
   function Time (This : in T) return Duration;

private

   type T is new Entity.T with
      record
         Prover     : Subject_Name; --  Prover involved.
         Result     : Subject_Name; --  "Valid", "Unknown", etc.
         Time       : Duration;     --  time spent during proof
         --  Steps -- part of the JSON data, but we don't care.
      end record;

   ---------------------------------------------------------------------------
   --  Image
   ---------------------------------------------------------------------------
   overriding
   function Image (This : in T) return String is
     (Ada.Tags.External_Tag (T'Class (This)'Tag) & ": (" &
        "Prover => " & To_String (This.Prover) &
        ", Result => " & To_String (This.Result) &
        ", Time => " & This.Time'Image & ")");

   Trivial_True : constant T := T'(Entity.T with
                                     Prover => To_Name ("Trivial"),
                                     Result => To_Name ("Valid"),
                                     Time   => 0.0);

   ---------------------------------------------------------------------------
   --  Prover
   ---------------------------------------------------------------------------
   not overriding
   function Prover (This : in T) return Subject_Name is
     (This.Prover);

   ---------------------------------------------------------------------------
   --  Result
   ---------------------------------------------------------------------------
   not overriding
   function Result (This : in T) return Subject_Name is
     (This.Result);

   ---------------------------------------------------------------------------
   --  Time
   ---------------------------------------------------------------------------
   not overriding
   function Time (This : in T) return Duration is
     (This.Time);

end SPAT.Proof_Attempt;
