'use client'

import { Container } from '../ui/Container'
import { useState } from 'react'
import SpinalInteraction from '../ui/SpinalInteraction'
import SpinalControls from '../ui/SpinalControls'

interface InteractiveProps {
  language: 'ko' | 'en'
}

// 반응형 크기 상수
const CIRCLE_SIZES = 'w-[400px] h-[200px] sm:w-[500px] sm:h-[250px] md:w-[650px] md:h-[325px] lg:w-[850px] lg:h-[425px] xl:w-[1050px] xl:h-[525px]'
const ANIMATION_COLOR = '#02D8C2'

type CurveType = 'healthy' | 'thoracic' | 'lumbar' | 'thoracolumbar' | 'combined'

export function Interactive({ language }: InteractiveProps) {
  const [severity, setSeverity] = useState(30)
  const [curveType, setCurveType] = useState<CurveType>('combined')

  // 다국어 텍스트 객체
  const content = {
    ko: {
      title: '스마트폰 하나로 완성되는 3D 척추 분석',
      subtitle: '모든 스마트폰에서 가능한 정밀하고 실제 크기의 3D 신체 모델링',
      instruction: '아래 컨트롤로 척추 각도 조정하기'
    },
    en: {
      title: '3D Spine Analysis Completed with Just One Smartphone',
      subtitle: 'Precise and actual-size 3D body modeling possible on all smartphones',
      instruction: 'Use controls below to adjust spine angle'
    }
  }
  
  const { title, subtitle, instruction } = content[language]

  return (
    <>
      <section className="relative min-h-screen sm:h-[500px] lg:min-h-screen h-[600px] lg:h-auto bg-gray-50 overflow-hidden lg:overflow-visible overflow-x-hidden">
        <Container size="1600" className="relative z-10 h-full">
          {/* 제목과 부제목을 위로 위치 */}
          <div className="pt-27 sm:pt-16 md:pt-20 lg:pt-24 pb-6 sm:pb-8 text-center">
            <h2 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-bold text-gray-900 mb-4 sm:mb-6 leading-tight px-4">
              {title}
            </h2>
            <p className="text-base sm:text-lg md:text-xl text-gray-600 max-w-4xl mx-auto px-4">
              {subtitle}
            </p>
          </div>

        </Container>

        {/* 하단에 고정된 반원 배경과 핸드폰 */}
        <div className="absolute bottom-0 left-0 right-0 flex justify-center">
          {/* 애니메이션 원 */}
          <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 pointer-events-none">
            <div 
              className={`rounded-t-full border-2 border-b-0 ${CIRCLE_SIZES}`}
              style={{
                borderColor: ANIMATION_COLOR,
                animation: 'singleExpandFade 3s ease-out infinite'
              }}
            />
          </div>
          
          {/* 반원 배경 */}
          <div className={`gradient-primary rounded-t-full ${CIRCLE_SIZES} relative`}>
            {/* 핸드폰 목업 - 반원 하단 중앙에 위치 */}
            <div className="absolute bottom-12 sm:bottom-4 md:bottom-0 lg:-bottom-8 xl:-bottom-12 left-1/2 transform -translate-x-1/2">
              {/* 간단한 안내 텍스트 - 핸드폰 상단 */}
              <div className="w-full absolute -top-6 sm:-top-8 md:-top-10 lg:-top-12 left-1/2 transform -translate-x-1/2 text-center z-40">
                <div className="flex items-center justify-center space-x-1 sm:space-x-2">
                  <img 
                    src="/images/drag.svg" 
                    alt="Drag icon"
                    className="w-3 h-3 sm:w-4 sm:h-4 md:w-5 md:h-5"
                  />
                  <p className="text-xs sm:text-sm md:text-base text-gray-600 font-medium">
                    {instruction}
                  </p>
                </div>
              </div>
              
              <div className="relative">
                {/* 핸드폰 이미지 - 데스크톱에서만 보이도록 */}
                <img 
                  src="/images/phone-img.png" 
                  alt="Phone Mockup"
                  className="w-64 h-auto lg:w-80 xl:w-96 relative z-20 drop-shadow-2xl hidden lg:block"
                />
                
                {/* 핸드폰 화면 영역 - SpinalInteraction 컴포넌트 */}
                {/* 데스크톱: 핸드폰 이미지 위에 절대 위치 */}
                <div className="absolute top-9 lg:top-10 xl:top-12 left-1/2 transform -translate-x-1/2 z-30 hidden lg:block">
                  <div className="w-52 h-[400px] lg:w-64 lg:h-[520px] xl:w-80 xl:h-[640px] rounded-3xl overflow-hidden">
                    <SpinalInteraction 
                      language={language} 
                      showControls={false}
                      severity={severity}
                      curveType={curveType}
                    />
                  </div>
                </div>

                {/* 모바일/태블릿: 커스텀 폰 프레임 */}
                <div className="lg:hidden relative w-64 md:w-72 mx-auto">
                  <div className="relative bg-gray-900 rounded-[2.5rem] p-3 shadow-2xl">
                    {/* 노치 영역 */}
                    <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-28 h-6 bg-gray-900 rounded-b-xl z-40" />
                    
                    {/* 인터랙션 컴포넌트 영역 */}
                    <div className="w-full h-[450px] rounded-[2rem] overflow-hidden relative">
                      <SpinalInteraction 
                        language={language} 
                        showControls={false}
                        severity={severity}
                        curveType={curveType}
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          {/* 컨트롤 패널 */}
          <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 w-full max-w-lg px-4 z-50">
            <SpinalControls
              language={language}
              severity={severity}
              curveType={curveType}
              onSeverityChange={setSeverity}
              onCurveTypeChange={setCurveType}
            />
          </div>
        </div>
      </section>
    </>
  )
}