import { useEffect, useRef, useState } from "react";
import { Outlet, useNavigate, Link } from "react-router-dom";
import NoteList from "./NoteList";
import { v4 as uuidv4 } from "uuid";
import { currentDate } from "./utils";
import { GoogleLogin, googleLogout, useGoogleLogin } from "@react-oauth/google";
import axios from "axios";

function Layout() {
  const navigate = useNavigate();
  // google stuff:
  const existingUser = localStorage.getItem("user");
  const [user, setUser] = useState(
    existingUser ? JSON.parse(existingUser) : null
  );
  const [profile, setProfile] = useState([]);
  const mainContainerRef = useRef(null);
  const [collapse, setCollapse] = useState(false);
  const [notes, setNotes] = useState([]);
  const [editMode, setEditMode] = useState(false);
  const [currentNote, setCurrentNote] = useState(-1);

  useEffect(() => {
    if (currentNote < 0) {
      return;
    }
    if (!editMode) {
      navigate(`/notes/${currentNote + 1}`);
      return;
    }
    navigate(`/notes/${currentNote + 1}/edit`);
  }, [notes]);

  const addNote = () => {
    setNotes([
      {
        id: uuidv4(),
        title: "Untitled",
        body: "",
        when: currentDate(),
      },
      ...notes,
    ]);
    setEditMode(true);
    setCurrentNote(0);
  };

  const saveNote = (note, index) => {
    note.body = note.body.replaceAll("<p></p>", "");
    setNotes([
      ...notes.slice(0, index),
      { ...note },
      ...notes.slice(index + 1),
    ]);
    setCurrentNote(index);
    setEditMode(false);
    saveNoteBackend(note);
  };

  const saveNoteBackend = async (note) => {
    const res = await fetch(
      `https://ppuz5i3cuwwqsmvsgn2p3pjstq0rvqkf.lambda-url.ca-central-1.on.aws/`,
      {
        method: "POST",
        headers: {
          "Content-type": "application/json",
          access_token: user.access_token,
        },
        body: JSON.stringify({ ...note, email: profile.email }),
      }
    );
    const jsonRes = await res.json();
    console.log(jsonRes);
  };

  const deleteNote = (index) => {
    deleteNoteBackend(index);
    setNotes([...notes.slice(0, index), ...notes.slice(index + 1)]);
    setCurrentNote(0);
    setEditMode(false);
  };

  const deleteNoteBackend = (index) => {
    fetch(
      `https://urpg4pehvyrhvfmdfuuf34rxeq0dtmxr.lambda-url.ca-central-1.on.aws?email=${profile.email}&id=${notes[index].id}`,
      {
        method: "DELETE",
        headers: {
          access_token: user.access_token,
        },
      }
    ).catch((error) => {
      console.log(error);
    });
  };

  const getNotes = async (profile) => {
    const email = profile.email;
    const res = await fetch(
      `https://vl5orb33qntszmiohkti4kgila0rxiue.lambda-url.ca-central-1.on.aws?email=${email}`,
      {
        method: "GET",
        headers: {
          Authorization: `Bearer ${user.access_token}`,
          Accept: "application/json",
          access_token: user.access_token,
        },
      }
    );
    const data = await res.json();
    setNotes(data);
  };

  const login = useGoogleLogin({
    onSuccess: (codeResponse) => {
      setUser(codeResponse);
      localStorage.setItem("user", JSON.stringify(codeResponse));
    },
    onError: (error) => console.log("Login Failed:", error),
  });

  useEffect(() => {
    if (user) {
      axios
        .get(
          `https://www.googleapis.com/oauth2/v1/userinfo?access_token=${user.access_token}`,
          {
            headers: {
              Authorization: `Bearer ${user.access_token}`,
              Accept: "application/json",
            },
          }
        )
        .then((res) => {
          setProfile(res.data);
        })
        .catch((err) => console.log(err));
    }
  }, [user]);

  const logOut = () => {
    googleLogout();
    setProfile(null);
  };

  useEffect(() => {
    if (profile) {
      localStorage.setItem("Profile", JSON.stringify(profile));
      getNotes(profile);
    }
    if (!profile) {
      navigate("/");
    }
  }, [profile]);

  return (
    <div id="container">
      <header>
        <aside>
          <button id="menu-button" onClick={() => setCollapse(!collapse)}>
            &#9776;
          </button>
        </aside>
        <div id="app-header">
          <h1>
            <Link to="/notes">Lotion</Link>
          </h1>
          <h6 id="app-moto">Like Notion, but worse.</h6>
        </div>
        {profile ? (
          <aside>
            <p id="user-log-name">{profile.email}</p>
            <button id="log-out-button" onClick={logOut}>
              Log out
            </button>
          </aside>
        ) : (
          <aside>&nbsp;</aside>
        )}
      </header>

      {profile ? (
        <div id="main-container" ref={mainContainerRef}>
          <aside id="sidebar" className={collapse ? "hidden" : null}>
            <header>
              <div id="notes-list-heading">
                <h2>Notes</h2>
                <button id="new-note-button" onClick={addNote}>
                  +
                </button>
              </div>
            </header>
            <div id="notes-holder">
              <NoteList notes={notes} />
            </div>
          </aside>
          <div id="write-box">
            <Outlet context={[notes, saveNote, deleteNote]} />
          </div>
        </div>
      ) : (
        <div id="sign-in">
          <GoogleLogin
            onSuccess={() => {
              login();
            }}
            onError={(error) => console.log("Login Failed:", error)}
          />
        </div>
      )}
    </div>
  );
}

export default Layout;
