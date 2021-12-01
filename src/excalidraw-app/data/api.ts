import { restoreElements } from "../../data/restore";
import { getSceneVersion } from "../../element";
import { ExcalidrawElement, FileId } from "../../element/types";
import Portal from "../collab/Portal";
import { BinaryFileData } from "../../types";
import * as request from "superagent";

const firebaseSceneVersionCache = new WeakMap<SocketIOClient.Socket, number>();

console.log("process.env as", process.env);

const LOCAL = {
  _saveDoc: async (roomId: string, elements: readonly ExcalidrawElement[]) => {
    localStorage.setItem(roomId, JSON.stringify(elements || []));
    console.log(`save room ${roomId} to local storage`);
  },
  _loadDoc: async (roomId: string): Promise<ExcalidrawElement[]> => {
    const str = localStorage.getItem(roomId);
    if (str) {
      try {
        const elements = JSON.parse(str);
        console.log(`load room ${roomId} to local storage`);
        return elements;
      } catch (err) {
        return [];
      }
    } else {
      return [];
    }
  },
};

const API = {
  _saveDoc: async (roomId: string, elements: readonly ExcalidrawElement[]) => {
    const url = `${
      process.env.REACT_APP_DOC_SERVER_URL || ""
    }/api/doc/save?id=${roomId}`;
    await request.post(url).send({ content: JSON.stringify(elements) });
  },

  _loadDoc: async (roomId: string): Promise<ExcalidrawElement[]> => {
    const url = `${
      process.env.REACT_APP_DOC_SERVER_URL || ""
    }/api/doc/load?id=${roomId}`;
    const { body } = await request.get(url);
    return JSON.parse(body.doc.content || "[]");
  },
};

const IMPL = API;

export const isSavedToFirebase = (
  portal: Portal,
  elements: readonly ExcalidrawElement[],
): boolean => {
  if (portal.socket && portal.roomId && portal.roomKey) {
    const sceneVersion = getSceneVersion(elements);

    return firebaseSceneVersionCache.get(portal.socket) === sceneVersion;
  }
  // if no room exists, consider the room saved so that we don't unnecessarily
  // prevent unload (there's nothing we could do at that point anyway)
  return true;
};
export const saveFilesToFirebase = async ({
  prefix,
  files,
}: {
  prefix: string;
  files: { id: FileId; buffer: Uint8Array }[];
}) => {
  const erroredFiles = new Map<FileId, true>();
  const savedFiles = new Map<FileId, true>();
  return Promise.resolve({ savedFiles, erroredFiles });
};
export const saveToFirebase = async (
  portal: Portal,
  elements: readonly ExcalidrawElement[],
) => {
  const { roomId, roomKey, socket } = portal;
  if (
    // if no room exists, consider the room saved because there's nothing we can
    // do at this point
    !roomId ||
    !roomKey ||
    !socket ||
    isSavedToFirebase(portal, elements)
  ) {
    return true;
  }

  const sceneVersion = getSceneVersion(elements);
  const didUpdate = await IMPL._saveDoc(roomId, elements);
  firebaseSceneVersionCache.set(socket, sceneVersion);
  return true;
};

export const loadFromFirebase = async (
  roomId: string,
  roomKey: string,
  socket: SocketIOClient.Socket | null,
): Promise<readonly ExcalidrawElement[] | null> => {
  const elements = await IMPL._loadDoc(roomId);

  if (socket) {
    firebaseSceneVersionCache.set(socket, getSceneVersion(elements));
  }
  return restoreElements(elements, null);
};
export const loadFilesFromFirebase = async (
  prefix: string,
  decryptionKey: string,
  filesIds: readonly FileId[],
) => {
  const loadedFiles: BinaryFileData[] = [];
  const erroredFiles = new Map<FileId, true>();
  console.log(`todo: loadFilesFromFirebase`);
  return Promise.resolve({ loadedFiles, erroredFiles });
};
