import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "R3X AI Companion",
  description: "A private AI companion powered by Ollama."
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
