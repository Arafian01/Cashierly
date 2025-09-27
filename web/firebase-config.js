// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBuomVDqWWqMDm0h3GGZI5vZuWIbSvSn90",
  authDomain: "inventory-app-f8ff6.firebaseapp.com",
  projectId: "inventory-app-f8ff6",
  storageBucket: "inventory-app-f8ff6.firebasestorage.app",
  messagingSenderId: "594527888713",
  appId: "1:594527888713:web:4abaaf662abffeb9086698",
  measurementId: "G-WS5HEG6QKV"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

export { firebaseConfig };
