import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Scoliscan - AI 척추 건강 모니터링',
  description: 'X-ray 없이 안전하게, AI 기술로 정확하게. 우리 아이의 척추 상태를 집에서 편안하게 살펴보세요.',
  keywords: ['척추', '건강', 'AI', '모니터링', '아이', '성장', '척추측만증'],
  authors: [{ name: 'Scoliscan Team' }],
  viewport: 'width=device-width, initial-scale=1',
  icons: {
    icon: '/images/favicon.ico',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ko" className="scroll-smooth">
      <head>
        <link 
          rel="stylesheet" 
          as="style" 
          crossOrigin="" 
          href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable.min.css" 
        />
      </head>
      <body className="font-sans">
        {children}
      </body>
    </html>
  )
}