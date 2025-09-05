'use client';

import React, { useState, useRef, useCallback, useEffect } from 'react';

interface SpinalInteractionProps {
  language: 'ko' | 'en';
  showControls?: boolean;
  severity?: number;
  curveType?: 'healthy' | 'thoracic' | 'lumbar' | 'thoracolumbar' | 'combined';
  onSeverityChange?: (value: number) => void;
  onCurveTypeChange?: (type: 'healthy' | 'thoracic' | 'lumbar' | 'thoracolumbar' | 'combined') => void;
}

const SpinalInteraction: React.FC<SpinalInteractionProps> = ({ 
  language, 
  showControls = true, 
  severity: externalSeverity,
  curveType: externalCurveType,
  onSeverityChange,
  onCurveTypeChange
}) => {
  const [internalSeverity, setInternalSeverity] = useState(30);
  const [internalCurveType, setInternalCurveType] = useState<'healthy' | 'thoracic' | 'lumbar' | 'thoracolumbar' | 'combined'>('combined');
  
  // Use external state if provided, otherwise use internal state
  const severity = externalSeverity ?? internalSeverity;
  const curveType = externalCurveType ?? internalCurveType;
  const svgRef = useRef<SVGSVGElement>(null);
  const animationRef = useRef<number>();
  const [time, setTime] = useState(0);

  // Animation loop for subtle breathing effect
  useEffect(() => {
    const animate = () => {
      setTime(prev => prev + 16); // ~60fps
      animationRef.current = requestAnimationFrame(animate);
    };
    animate();
    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, []);

  const handleSliderChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseInt(e.target.value);
    if (onSeverityChange) {
      onSeverityChange(value);
    } else {
      setInternalSeverity(value);
    }
  };

  const handleCurveTypeChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const value = e.target.value as 'healthy' | 'thoracic' | 'lumbar' | 'thoracolumbar' | 'combined';
    if (onCurveTypeChange) {
      onCurveTypeChange(value);
    } else {
      setInternalCurveType(value);
    }
  };

  // Gaussian function for curve distribution
  const gauss = (t: number, mu: number, sigma: number) => {
    const z = (t - mu) / sigma;
    return Math.exp(-0.5 * z * z);
  };

  // Calculate curve X position based on original algorithm
  const curveX = (t: number, type: string, A: number, time: number) => {
    if (type === 'healthy' || A === 0) return 0;
    
    let x = 0;
    if (type === 'thoracic') x = A * gauss(t, 0.38, 0.12);
    else if (type === 'lumbar') x = A * gauss(t, 0.78, 0.12);
    else if (type === 'thoracolumbar') x = A * gauss(t, 0.58, 0.20);
    else if (type === 'combined') x = A * 0.90 * gauss(t, 0.33, 0.11) - A * 0.90 * gauss(t, 0.75, 0.11);
    
    // Subtle breathing animation
    const sway = Math.sin(time * 0.0008 + t * 3.2) * Math.min(3, A * 0.07);
    return x + sway;
  };

  // Generate vertebrae positions
  const generateVertebraeData = () => {
    const W = 400, H = 600;
    const cx = W / 2;
    const topY = H * 0.18;
    const botY = H * 0.88;
    const N = 18; // Number of vertebrae
    const A = (severity / 60) * 60; // Amplitude based on severity
    
    const vertebrae = [];
    let spinalPath = '';
    
    for (let i = 0; i < N; i++) {
      const t = i / (N - 1);
      const y = topY + t * (botY - topY);
      const x = cx + curveX(t, curveType, A, time);
      
      // Calculate rotation angle
      const dt = 0.002;
      const xl = cx + curveX(Math.max(0, t - dt), curveType, A, time);
      const xr = cx + curveX(Math.min(1, t + dt), curveType, A, time);
      const dy = (botY - topY) * dt * 2;
      const ang = Math.atan2(dy, xr - xl) * 180 / Math.PI + 90;
      
      vertebrae.push({ x, y, rotation: ang });
      spinalPath += (i ? 'L' : 'M') + x.toFixed(1) + ',' + y.toFixed(1) + ' ';
    }
    
    return { vertebrae, spinalPath, glowOpacity: severity === 0 ? 0 : 0.2 };
  };

  const { vertebrae, spinalPath, glowOpacity } = generateVertebraeData();

  return (
    <>
      {/* Main spine visualization area */}
      <div className="relative w-full h-full min-h-[600px] bg-white rounded-2xl overflow-hidden">
        {/* Background body image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-40"
          style={{
            backgroundImage: 'url(/images/interact.png)',
            backgroundSize: 'contain'
          }}
        />
        
        {/* SVG Spine visualization */}
        <svg
          ref={svgRef}
          className="absolute inset-0 w-full h-full"
          viewBox="0 0 400 600"
          preserveAspectRatio="xMidYMid meet"
        >
          {/* Glow effect path */}
          <path
            d={spinalPath}
            stroke="#FF6E4E"
            strokeWidth="20"
            fill="none"
            opacity={glowOpacity}
            style={{ pointerEvents: 'none' }}
          />
          
          {/* Individual vertebrae */}
          <g>
            {vertebrae.map((vertebra, index) => (
              <g
                key={index}
                transform={`translate(${vertebra.x.toFixed(2)},${vertebra.y.toFixed(2)}) rotate(${vertebra.rotation.toFixed(2)})`}
              >
                {/* Main vertebra body - smaller size */}
                <rect
                  x="-10"
                  y="-5"
                  width="20"
                  height="10"
                  rx="3"
                  fill="#F4E8D5"
                  stroke="#C2B79C"
                  strokeWidth="1"
                />
                
                {/* Central teal pillar - smaller */}
                <rect
                  x="-1.5"
                  y="-4"
                  width="3"
                  height="8"
                  rx="1.5"
                  fill="#176f72"
                  opacity="0.95"
                />
                
                {/* Central dot - smaller */}
                <circle
                  cx="0"
                  cy="0"
                  r="1.5"
                  fill="#1b8b8d"
                />
              </g>
            ))}
          </g>
        </svg>
        
        {/* Floating angle indicator - top right */}
        <div className="absolute top-4 right-4 bg-black/80 text-white rounded-lg px-3 py-2">
          <div className="text-xs opacity-80 mb-1">
            {language === 'ko' ? '각도' : 'Angle'}
          </div>
          <div className="font-bold text-lg">
            {curveType === 'healthy' ? '0' : severity}°
          </div>
        </div>
      </div>
      
      {/* External control panel - only show when requested */}
      {showControls && (
        <div className="mt-4">
          <div className="bg-primary-600 text-white rounded-2xl px-4 py-3 flex items-center gap-3 shadow-lg justify-center flex-wrap text-sm max-w-md mx-auto">
            {/* Curve type selector */}
            <span className="font-bold">
              {language === 'ko' ? '유형' : 'Type'}
            </span>
            <select
              value={curveType}
              onChange={handleCurveTypeChange}
              className="border-none rounded-xl px-2 py-1 font-bold text-gray-800 bg-white text-xs"
            >
              <option value="combined">{language === 'ko' ? 'S자형 (이중)' : 'Double Major (S)'}</option>
              <option value="healthy">{language === 'ko' ? '정상' : 'Healthy'}</option>
              <option value="thoracic">{language === 'ko' ? '흉추' : 'Thoracic'}</option>
              <option value="lumbar">{language === 'ko' ? '요추' : 'Lumbar'}</option>
              <option value="thoracolumbar">{language === 'ko' ? '흉요추' : 'Thoraco-Lumbar'}</option>
            </select>
            
            {/* Severity label */}
            <span className="font-bold">
              {language === 'ko' ? '심각도' : 'Severity'}
            </span>
            
            {/* Range slider */}
            <div className="relative flex items-center">
              <input
                type="range"
                min="0"
                max="60"
                value={severity}
                onChange={handleSliderChange}
                className="w-[140px] h-2 bg-white/50 rounded-full outline-none cursor-pointer"
                style={{
                  background: `linear-gradient(to right, #ffffff 0%, #ffffff ${(severity/60)*100}%, rgba(255,255,255,0.5) ${(severity/60)*100}%, rgba(255,255,255,0.5) 100%)`,
                  WebkitAppearance: 'none',
                  appearance: 'none'
                }}
              />
            </div>
            
            {/* Degree display */}
            <div className="bg-white text-gray-800 rounded-full px-2 py-1 font-bold text-xs min-w-[40px] text-center">
              {severity}°
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default SpinalInteraction;